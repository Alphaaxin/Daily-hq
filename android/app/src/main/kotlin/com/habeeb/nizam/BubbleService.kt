package com.habeeb.nizam

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import kotlin.math.abs

/** Optional draggable gold ₹ bubble over all apps; tap opens Quick Log. */
class BubbleService : Service() {
    private var wm: WindowManager? = null
    private var bubble: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startAsForeground()
        showBubble()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onDestroy() {
        bubble?.let { runCatching { wm?.removeView(it) } }
        bubble = null
        super.onDestroy()
    }

    private fun dp(v: Float) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, resources.displayMetrics).toInt()

    private fun startAsForeground() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= 26) {
            nm.createNotificationChannel(
                NotificationChannel("bubble", "₹ bubble", NotificationManager.IMPORTANCE_MIN).apply {
                    description = "Keeps the floating ₹ bubble available"
                    setShowBadge(false)
                }
            )
        }
        val open = PendingIntent.getActivity(
            this, 2, QuickLogActivity.intent(this), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val n: Notification = (if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, "bubble") else @Suppress("DEPRECATION") Notification.Builder(this))
            .setSmallIcon(R.drawable.ic_stat_nizam)
            .setContentTitle("₹ bubble is on")
            .setContentText("Tap the bubble (or here) to log money")
            .setContentIntent(open)
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(77, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(77, n)
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun showBubble() {
        val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        this.wm = wm
        val size = dp(54f)
        val view = TextView(this).apply {
            text = "₹"
            textSize = 24f
            setTextColor(0xFF17120A.toInt())
            gravity = Gravity.CENTER
            contentDescription = "Log money"
            background = GradientDrawable(
                GradientDrawable.Orientation.TL_BR,
                intArrayOf(0xFFF0D59A.toInt(), 0xFFD9B46A.toInt(), 0xFFA9823F.toInt())
            ).apply {
                shape = GradientDrawable.OVAL
                setStroke(dp(1f), 0x40FFFFFF)
            }
            elevation = dp(8f).toFloat()
        }
        val type = if (Build.VERSION.SDK_INT >= 26) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE
        val lp = WindowManager.LayoutParams(
            size, size, type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = resources.displayMetrics.widthPixels - size - dp(12f)
            y = resources.displayMetrics.heightPixels / 3
        }
        var downX = 0f
        var downY = 0f
        var startX = 0
        var startY = 0
        var moved = false
        view.setOnTouchListener { _, e ->
            when (e.action) {
                MotionEvent.ACTION_DOWN -> {
                    downX = e.rawX; downY = e.rawY; startX = lp.x; startY = lp.y; moved = false; true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = e.rawX - downX
                    val dy = e.rawY - downY
                    if (abs(dx) > dp(6f) || abs(dy) > dp(6f)) moved = true
                    lp.x = startX + dx.toInt()
                    lp.y = startY + dy.toInt()
                    runCatching { wm.updateViewLayout(view, lp) }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (!moved) {
                        startActivity(QuickLogActivity.intent(this))
                    } else {
                        // Snap to the nearest side.
                        val w = resources.displayMetrics.widthPixels
                        lp.x = if (lp.x + size / 2 < w / 2) dp(8f) else w - size - dp(8f)
                        runCatching { wm.updateViewLayout(view, lp) }
                    }
                    true
                }
                else -> false
            }
        }
        runCatching { wm.addView(view, lp) }.onSuccess { bubble = view }
    }
}
