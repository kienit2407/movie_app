package com.example.movie_app

import android.content.Intent
import android.net.Uri
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import androidx.mediarouter.app.MediaRouteButton
import androidx.mediarouter.media.MediaRouteSelector
import androidx.mediarouter.media.MediaRouter
import com.google.android.gms.cast.MediaInfo
import com.google.android.gms.cast.MediaLoadRequestData
import com.google.android.gms.cast.MediaMetadata
import com.google.android.gms.cast.MediaSeekOptions
import com.google.android.gms.cast.MediaStatus
import com.google.android.gms.cast.framework.CastButtonFactory
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManagerListener
import com.google.android.gms.cast.framework.media.RemoteMediaClient
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.images.WebImage
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class GoogleCastBridge(
    private val activity: MainActivity,
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.example.movie_app/casting"
    }

    private var castContext: CastContext? = null
    private var routeButton: MediaRouteButton? = null
    private var pendingMedia: CastMediaPayload? = null
    private var remoteMediaClient: RemoteMediaClient? = null
    private var mediaRouter: MediaRouter? = null
    private var discoverySelector: MediaRouteSelector? = null
    private var discoveryActive = false
    private var lastPositionMs = 0L
    private var lastWasPlaying = false

    private val discoveryCallback = object : MediaRouter.Callback() {
        override fun onRouteAdded(router: MediaRouter, route: MediaRouter.RouteInfo) {
            publishDiscoveredDevices()
        }

        override fun onRouteRemoved(router: MediaRouter, route: MediaRouter.RouteInfo) {
            publishDiscoveredDevices()
        }

        override fun onRouteChanged(router: MediaRouter, route: MediaRouter.RouteInfo) {
            publishDiscoveredDevices()
        }

        override fun onProviderChanged(
            router: MediaRouter,
            provider: MediaRouter.ProviderInfo,
        ) {
            publishDiscoveredDevices()
        }
    }

    private val remoteMediaCallback = object : RemoteMediaClient.Callback() {
        override fun onStatusUpdated() {
            notifyRemoteStatus()
        }

        override fun onMetadataUpdated() {
            notifyRemoteStatus()
        }
    }

    private val sessionListener = object : SessionManagerListener<CastSession> {
        override fun onSessionStarting(session: CastSession) {
            notifyFlutter("connecting", session)
        }

        override fun onSessionStarted(session: CastSession, sessionId: String) {
            attachRemoteClient(session)
            notifyFlutter("connected", session)
            pendingMedia?.let { loadMedia(session, it) }
        }

        override fun onSessionStartFailed(session: CastSession, error: Int) {
            notifyFlutter("disconnected", session, errorCode = error)
        }

        override fun onSessionEnding(session: CastSession) {
            captureRemoteState()
        }

        override fun onSessionEnded(session: CastSession, error: Int) {
            detachRemoteClient()
            notifyFlutter("disconnected", session, errorCode = error)
        }

        override fun onSessionResuming(session: CastSession, sessionId: String) {
            notifyFlutter("connecting", session)
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            attachRemoteClient(session)
            notifyFlutter("connected", session)
        }

        override fun onSessionResumeFailed(session: CastSession, error: Int) {
            notifyFlutter("disconnected", session, errorCode = error)
        }

        override fun onSessionSuspended(session: CastSession, reason: Int) {
            captureRemoteState()
            notifyFlutter("connecting", session, errorCode = reason)
        }
    }

    init {
        initializeCast()
    }

    private fun initializeCast(): Boolean {
        if (castContext != null) return true
        if (
            GoogleApiAvailability.getInstance()
                .isGooglePlayServicesAvailable(activity) != ConnectionResult.SUCCESS
        ) {
            return false
        }

        return try {
            val context = CastContext.getSharedInstance(activity)
            castContext = context
            context.sessionManager.addSessionManagerListener(
                sessionListener,
                CastSession::class.java,
            )
            context.sessionManager.currentCastSession?.let {
                attachRemoteClient(it)
                notifyFlutter("connected", it)
            }
            true
        } catch (_: Exception) {
            false
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "showAirPlayPicker" -> result.success(false)
            "isGoogleCastAvailable" -> result.success(initializeCast())
            "startGoogleCastDiscovery" -> startGoogleCastDiscovery(result)
            "stopGoogleCastDiscovery" -> {
                stopGoogleCastDiscovery()
                result.success(null)
            }
            "connectGoogleCastDevice" -> connectGoogleCastDevice(call, result)
            "showGoogleCastPicker" -> showGoogleCastPicker(call, result)
            "loadGoogleCastMedia" -> loadGoogleCastMedia(call, result)
            "googleCastPlay" -> result.success(remoteMediaClient?.play() != null)
            "googleCastPause" -> result.success(remoteMediaClient?.pause() != null)
            "googleCastSeek" -> seekRemote(call, result)
            "googleCastStop" -> {
                castContext?.sessionManager?.endCurrentSession(true)
                result.success(true)
            }
            "showGoogleCastControls" -> showExpandedControls(result)
            else -> result.notImplemented()
        }
    }

    private fun startGoogleCastDiscovery(result: MethodChannel.Result) {
        if (!initializeCast()) {
            result.success(emptyList<Map<String, String>>())
            return
        }

        val context = castContext ?: run {
            result.success(emptyList<Map<String, String>>())
            return
        }
        val router = mediaRouter ?: MediaRouter.getInstance(activity).also {
            mediaRouter = it
        }
        val selector = context.mergedSelector ?: MediaRouteSelector.EMPTY
        discoverySelector = selector
        if (!discoveryActive) {
            router.addCallback(
                selector,
                discoveryCallback,
                MediaRouter.CALLBACK_FLAG_PERFORM_ACTIVE_SCAN,
            )
            discoveryActive = true
        }
        result.success(currentDiscoveredDevices())
    }

    private fun stopGoogleCastDiscovery() {
        if (!discoveryActive) return
        mediaRouter?.removeCallback(discoveryCallback)
        discoveryActive = false
    }

    private fun currentDiscoveredRoutes(): List<MediaRouter.RouteInfo> {
        val router = mediaRouter ?: return emptyList()
        val selector = discoverySelector ?: return emptyList()
        return router.routes.filter { route ->
            route.isEnabled &&
                !route.isDefault &&
                !route.isDeviceSpeaker &&
                route.matchesSelector(selector)
        }
    }

    private fun currentDiscoveredDevices(): List<Map<String, String>> =
        currentDiscoveredRoutes().map { route ->
            buildMap {
                put("id", route.id)
                put("name", route.name)
                route.description?.takeIf { it.isNotBlank() }?.let {
                    put("description", it)
                }
            }
        }

    private fun publishDiscoveredDevices() {
        activity.runOnUiThread {
            channel.invokeMethod(
                "googleCastDevicesChanged",
                currentDiscoveredDevices(),
            )
        }
    }

    private fun connectGoogleCastDevice(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        if (!initializeCast()) {
            result.success(false)
            return
        }
        val media = CastMediaPayload.from(call.arguments)
        val routeId = call.argument<String>("deviceId")
        val route = currentDiscoveredRoutes().firstOrNull { it.id == routeId }
        if (media == null || route == null) {
            result.success(false)
            return
        }

        pendingMedia = media
        route.select()
        result.success(true)
    }

    private fun showGoogleCastPicker(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        if (!initializeCast()) {
            result.success(false)
            return
        }

        val media = CastMediaPayload.from(call.arguments)
        if (media == null) {
            result.error("invalid_media", "Thiếu URL video để phát trên TV.", null)
            return
        }
        pendingMedia = media

        castContext?.sessionManager?.currentCastSession?.let { session ->
            attachRemoteClient(session)
            loadMedia(session, media)
        }

        val button = ensureRouteButton()
        button.post {
            try {
                result.success(button.showDialog())
            } catch (error: Exception) {
                result.error("cast_picker_failed", error.message, null)
            }
        }
    }

    private fun loadGoogleCastMedia(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val media = CastMediaPayload.from(call.arguments)
        val session = castContext?.sessionManager?.currentCastSession
        if (media == null || session == null) {
            result.success(false)
            return
        }
        pendingMedia = media
        loadMedia(session, media)
        result.success(true)
    }

    private fun ensureRouteButton(): MediaRouteButton {
        routeButton?.let { return it }
        val button = MediaRouteButton(activity).apply {
            alpha = 0.01f
            visibility = View.VISIBLE
        }
        CastButtonFactory.setUpMediaRouteButton(activity.applicationContext, button)
        activity.addContentView(
            button,
            FrameLayout.LayoutParams(2, 2, Gravity.TOP or Gravity.END),
        )
        routeButton = button
        return button
    }

    private fun loadMedia(session: CastSession, media: CastMediaPayload) {
        val client = session.remoteMediaClient ?: return
        attachRemoteClient(session)

        val metadata = MediaMetadata(MediaMetadata.MEDIA_TYPE_MOVIE).apply {
            putString(MediaMetadata.KEY_TITLE, media.movieName)
            putString(MediaMetadata.KEY_SUBTITLE, media.subtitle)
            if (media.posterUrl.isNotBlank()) {
                runCatching { addImage(WebImage(Uri.parse(media.posterUrl))) }
            }
        }
        val mediaInfo = MediaInfo.Builder(media.url)
            .setStreamType(MediaInfo.STREAM_TYPE_BUFFERED)
            .setContentType(media.contentType)
            .setMetadata(metadata)
            .apply {
                if (media.durationMs > 0) setStreamDuration(media.durationMs)
            }
            .build()
        val request = MediaLoadRequestData.Builder()
            .setMediaInfo(mediaInfo)
            .setAutoplay(true)
            .setCurrentTime(media.positionMs.coerceAtLeast(0))
            .build()

        notifyFlutter("loading", session)
        client.load(request)
    }

    private fun seekRemote(call: MethodCall, result: MethodChannel.Result) {
        val positionMs = call.argument<Number>("positionMs")?.toLong()
        val client = remoteMediaClient
        if (positionMs == null || client == null) {
            result.success(false)
            return
        }
        val options = MediaSeekOptions.Builder()
            .setPosition(positionMs.coerceAtLeast(0))
            .setResumeState(MediaSeekOptions.RESUME_STATE_UNCHANGED)
            .build()
        client.seek(options)
        result.success(true)
    }

    private fun showExpandedControls(result: MethodChannel.Result) {
        if (castContext?.sessionManager?.currentCastSession == null) {
            result.success(false)
            return
        }
        activity.startActivity(Intent(activity, ExpandedControlsActivity::class.java))
        result.success(true)
    }

    private fun attachRemoteClient(session: CastSession) {
        val client = session.remoteMediaClient ?: return
        if (remoteMediaClient === client) return
        detachRemoteClient()
        remoteMediaClient = client
        client.registerCallback(remoteMediaCallback)
        captureRemoteState()
    }

    private fun detachRemoteClient() {
        remoteMediaClient?.unregisterCallback(remoteMediaCallback)
        remoteMediaClient = null
    }

    private fun captureRemoteState() {
        val client = remoteMediaClient ?: return
        lastPositionMs = client.approximateStreamPosition.coerceAtLeast(0)
        lastWasPlaying =
            client.mediaStatus?.playerState == MediaStatus.PLAYER_STATE_PLAYING
    }

    private fun notifyRemoteStatus() {
        val session = castContext?.sessionManager?.currentCastSession ?: return
        val client = remoteMediaClient ?: return
        captureRemoteState()
        val playerState = client.mediaStatus?.playerState
        val state = when (playerState) {
            MediaStatus.PLAYER_STATE_PLAYING -> "playing"
            MediaStatus.PLAYER_STATE_PAUSED -> "paused"
            MediaStatus.PLAYER_STATE_BUFFERING,
            MediaStatus.PLAYER_STATE_LOADING -> "loading"
            else -> "connected"
        }
        notifyFlutter(state, session)
    }

    private fun notifyFlutter(
        state: String,
        session: CastSession?,
        errorCode: Int? = null,
    ) {
        activity.runOnUiThread {
            channel.invokeMethod(
                "googleCastStateChanged",
                mapOf(
                    "state" to state,
                    "deviceName" to session?.castDevice?.friendlyName,
                    "positionMs" to lastPositionMs,
                    "wasPlaying" to lastWasPlaying,
                    "errorCode" to errorCode,
                ),
            )
        }
    }

    fun dispose() {
        stopGoogleCastDiscovery()
        castContext?.sessionManager?.removeSessionManagerListener(
            sessionListener,
            CastSession::class.java,
        )
        detachRemoteClient()
        routeButton?.let { button ->
            (button.parent as? android.view.ViewGroup)?.removeView(button)
        }
        routeButton = null
        castContext = null
    }
}

private data class CastMediaPayload(
    val url: String,
    val movieName: String,
    val subtitle: String,
    val posterUrl: String,
    val positionMs: Long,
    val durationMs: Long,
) {
    val contentType: String
        get() {
            val cleanUrl = url.substringBefore('?').lowercase()
            return when {
                cleanUrl.endsWith(".m3u8") -> "application/x-mpegURL"
                cleanUrl.endsWith(".mpd") -> "application/dash+xml"
                cleanUrl.endsWith(".webm") -> "video/webm"
                else -> "video/mp4"
            }
        }

    companion object {
        fun from(arguments: Any?): CastMediaPayload? {
            val map = arguments as? Map<*, *> ?: return null
            val url = map["url"]?.toString()?.trim().orEmpty()
            if (!url.startsWith("http://") && !url.startsWith("https://")) {
                return null
            }
            val episodeName = map["episodeName"]?.toString()?.trim().orEmpty()
            val serverName = map["serverName"]?.toString()?.trim().orEmpty()
            val subtitle = listOf(episodeName, serverName)
                .filter { it.isNotBlank() }
                .joinToString(" • ")

            return CastMediaPayload(
                url = url,
                movieName = map["movieName"]?.toString()?.trim().orEmpty(),
                subtitle = subtitle,
                posterUrl = map["posterUrl"]?.toString()?.trim().orEmpty(),
                positionMs = (map["positionMs"] as? Number)?.toLong() ?: 0,
                durationMs = (map["durationMs"] as? Number)?.toLong() ?: 0,
            )
        }
    }
}
