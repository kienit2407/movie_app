package com.example.movie_app

import android.app.usage.StorageStatsManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.OrientationEventListener
import android.hardware.SensorManager
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val DEVICE_ORIENTATION_CHANNEL =
            "com.kinit.movieapp/device_orientation"
        private const val APP_STORAGE_CHANNEL = "com.kinit.movieapp/app_storage"
    }

    private var googleCastBridge: GoogleCastBridge? = null
    private var orientationEventChannel: EventChannel? = null
    private var orientationListener: OrientationEventListener? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Cho app tràn viền (edge-to-edge)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            GoogleCastBridge.CHANNEL_NAME,
        )
        googleCastBridge = GoogleCastBridge(this, channel)
        channel.setMethodCallHandler(googleCastBridge)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_STORAGE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "getAppDataSizeBytes") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            Thread {
                try {
                    val bytes = calculateAppDataSizeBytes()
                    runOnUiThread { result.success(bytes) }
                } catch (error: Exception) {
                    runOnUiThread {
                        result.error(
                            "app_storage_failed",
                            error.localizedMessage,
                            null,
                        )
                    }
                }
            }.start()
        }

        orientationEventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEVICE_ORIENTATION_CHANNEL,
        ).also { eventChannel ->
            eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    var lastOrientation: String? = null
                    orientationListener?.disable()
                    orientationListener = object : OrientationEventListener(
                        this@MainActivity,
                        SensorManager.SENSOR_DELAY_UI,
                    ) {
                        override fun onOrientationChanged(orientation: Int) {
                            if (orientation == ORIENTATION_UNKNOWN || !isSystemAutoRotateEnabled()) {
                                return
                            }

                            val nextOrientation = when (orientation) {
                                in 315..359, in 0..44 -> "portraitUp"
                                in 45..134 -> "landscapeRight"
                                in 225..314 -> "landscapeLeft"
                                else -> null
                            } ?: return

                            if (nextOrientation == lastOrientation) return
                            lastOrientation = nextOrientation
                            events.success(nextOrientation)
                        }
                    }.also { listener ->
                        if (listener.canDetectOrientation()) listener.enable()
                    }
                }

                override fun onCancel(arguments: Any?) {
                    orientationListener?.disable()
                    orientationListener = null
                }
            })
        }
    }

    private fun isSystemAutoRotateEnabled(): Boolean {
        return Settings.System.getInt(
            contentResolver,
            Settings.System.ACCELEROMETER_ROTATION,
            0,
        ) == 1
    }

    private fun calculateAppDataSizeBytes(): Long {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val storageStatsManager = getSystemService(
                    Context.STORAGE_STATS_SERVICE,
                ) as StorageStatsManager
                val stats = storageStatsManager.queryStatsForUid(
                    applicationInfo.storageUuid,
                    applicationInfo.uid,
                )
                // dataBytes already contains cacheBytes. Do not add it again.
                return stats.dataBytes
            } catch (_: Exception) {
                // Fall back to walking the app-owned directories below.
            }
        }

        val roots = buildList {
            add(applicationInfo.dataDir)
            addAll(getExternalFilesDirs(null).filterNotNull().map { it.path })
            addAll(externalCacheDirs.filterNotNull().map { it.path })
            addAll(externalMediaDirs.filterNotNull().map { it.path })
        }

        return roots
            .distinct()
            .sumOf { path -> directorySizeBytes(java.io.File(path)) }
    }

    private fun directorySizeBytes(root: java.io.File): Long {
        if (!root.exists()) return 0L
        return root.walkTopDown().sumOf { file ->
            if (file.isFile) runCatching { file.length() }.getOrDefault(0L) else 0L
        }
    }

    override fun onDestroy() {
        orientationListener?.disable()
        orientationListener = null
        orientationEventChannel?.setStreamHandler(null)
        orientationEventChannel = null
        googleCastBridge?.dispose()
        googleCastBridge = null
        super.onDestroy()
    }
}
