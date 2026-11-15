package com.habeeb.nizam

import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** The "nizam/native" method channel shared by the main app and the Quick Log popup. */
object NativeChannel {
    const val NAME = "nizam/native"

    fun register(engine: FlutterEngine, activity: Activity, onFinishPopup: (() -> Unit)? = null) {
        val ctx: Context = activity.applicationContext
        MethodChannel(engine.dartExecutor.binaryMessenger, NAME).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "canDrawOverlays" -> result.success(Settings.canDrawOverlays(ctx))
                    "requestOverlay" -> {
                        activity.startActivity(
                            Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:${ctx.packageName}"))
                        )
                        result.success(true)
                    }
                    "startBubble" -> {
                        if (!Settings.canDrawOverlays(ctx)) {
                            result.success(false)
                        } else {
                            val i = Intent(ctx, BubbleService::class.java)
                            if (Build.VERSION.SDK_INT >= 26) ctx.startForegroundService(i) else ctx.startService(i)
                            result.success(true)
                        }
                    }
                    "stopBubble" -> {
                        ctx.stopService(Intent(ctx, BubbleService::class.java))
                        result.success(true)
                    }
                    "hasDndAccess" -> result.success(notifications(ctx).isNotificationPolicyAccessGranted)
                    "requestDndAccess" -> {
                        activity.startActivity(Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS))
                        result.success(true)
                    }
                    "setDnd" -> {
                        val nm = notifications(ctx)
                        if (!nm.isNotificationPolicyAccessGranted) {
                            result.success(false)
                        } else {
                            val on = call.arguments as? Boolean ?: false
                            nm.setInterruptionFilter(
                                if (on) NotificationManager.INTERRUPTION_FILTER_PRIORITY
                                else NotificationManager.INTERRUPTION_FILTER_ALL
                            )
                            result.success(true)
                        }
                    }
                    "finishPopup" -> {
                        if (onFinishPopup != null) {
                            onFinishPopup()
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("native", e.message, null)
            }
        }
    }

    private fun notifications(ctx: Context) =
        ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
}
