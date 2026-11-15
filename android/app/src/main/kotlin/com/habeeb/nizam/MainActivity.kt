package com.habeeb.nizam

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        LaunchData.capture(intent)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NativeChannel.register(flutterEngine, this)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nizam/launch")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        LaunchData.capture(intent)
        if (LaunchData.hasData()) channel?.invokeMethod("launch", LaunchData.take())
    }
}
