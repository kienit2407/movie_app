package com.example.movie_app

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var googleCastBridge: GoogleCastBridge? = null

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
    }

    override fun onDestroy() {
        googleCastBridge?.dispose()
        googleCastBridge = null
        super.onDestroy()
    }
}
