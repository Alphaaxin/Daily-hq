package com.habeeb.nizam

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine

/**
 * A see-through activity that shows only the ₹ Quick Log popup on top of
 * whatever app is open. Opened by the Quick Settings tile, the home-screen
 * widget and the floating bubble. Needs no overlay permission.
 */
class QuickLogActivity : FlutterActivity() {
    override fun getInitialRoute(): String = "/quicklog"

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NativeChannel.register(flutterEngine, this) { finishAndRemoveTask() }
    }

    override fun onPause() {
        super.onPause()
        overridePendingTransition(0, 0)
    }

    companion object {
        fun intent(ctx: Context): Intent =
            Intent(ctx, QuickLogActivity::class.java).addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NO_ANIMATION
            )
    }
}
