package com.habeeb.nizam

import android.app.Activity
import android.app.AppOpsManager
import android.app.NotificationManager
import android.app.usage.UsageStatsManager
import android.content.pm.ApplicationInfo
import android.os.Process
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
                    "startRecording" -> {
                        val dir = call.argument<String>("dir")!!
                        val title = call.argument<String>("title") ?: "Recording"
                        result.success(RecordingService.start(ctx, dir, title))
                    }
                    "stopRecording" -> result.success(RecordingService.stop(ctx))
                    "recordingStatus" -> result.success(
                        mapOf(
                            "recording" to RecordingService.recording,
                            "startedAt" to RecordingService.startedAt,
                            "parts" to synchronized(RecordingService.parts) { RecordingService.parts.toList() },
                        )
                    )
                    "hasUsageAccess" -> result.success(hasUsageAccess(ctx))
                    "requestUsageAccess" -> {
                        activity.startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(true)
                    }
                    "usageSince" -> {
                        if (!hasUsageAccess(ctx)) {
                            result.success(emptyList<Map<String, Any>>())
                        } else {
                            val from = (call.arguments as Number).toLong()
                            result.success(usageSince(ctx, from))
                        }
                    }
                    "takeLaunch" -> result.success(LaunchData.take())
                    "updateWidgets" -> {
                        @Suppress("UNCHECKED_CAST")
                        val m = (call.arguments as Map<String, Any?>).mapValues { it.value?.toString() ?: "" }
                        TodayWidgetProvider.push(ctx, m)
                        result.success(true)
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

    private fun hasUsageAccess(ctx: Context): Boolean {
        val ops = ctx.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= 29) {
            ops.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), ctx.packageName)
        } else {
            @Suppress("DEPRECATION")
            ops.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), ctx.packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /** Foreground time per app since [from] (epoch ms), largest first. */
    private fun usageSince(ctx: Context, from: Long): List<Map<String, Any>> {
        val usm = ctx.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usm.queryAndAggregateUsageStats(from, System.currentTimeMillis())
        val pm = ctx.packageManager
        return stats.values
            .filter { it.totalTimeInForeground > 60_000 && it.packageName != ctx.packageName }
            .sortedByDescending { it.totalTimeInForeground }
            .take(25)
            .map {
                val label = runCatching {
                    pm.getApplicationLabel(pm.getApplicationInfo(it.packageName, 0)).toString()
                }.getOrDefault(it.packageName)
                mapOf("package" to it.packageName, "label" to label, "ms" to it.totalTimeInForeground)
            }
    }

    private fun notifications(ctx: Context) =
        ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
}
