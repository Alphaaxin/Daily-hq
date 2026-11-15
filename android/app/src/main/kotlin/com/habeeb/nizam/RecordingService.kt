package com.habeeb.nizam

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.MediaRecorder
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import java.io.File

/**
 * Records meetings / voice notes in the background (screen off) as AAC
 * chunks of [CHUNK_MS] each, so long recordings can be sent to the AI in
 * pieces and nothing is lost if one upload fails.
 */
class RecordingService : Service() {
    companion object {
        const val CHUNK_MS = 10 * 60 * 1000L
        @Volatile var recording = false
        @Volatile var startedAt = 0L
        val parts = mutableListOf<String>()
        var label = "Recording"

        fun start(ctx: Context, dir: String, title: String): Boolean {
            if (recording) return false
            parts.clear()
            label = title
            val i = Intent(ctx, RecordingService::class.java).putExtra("dir", dir)
            if (Build.VERSION.SDK_INT >= 26) ctx.startForegroundService(i) else ctx.startService(i)
            return true
        }

        fun stop(ctx: Context): List<String> {
            ctx.stopService(Intent(ctx, RecordingService::class.java))
            return synchronized(parts) { parts.toList() }
        }
    }

    private var recorder: MediaRecorder? = null
    private var dir: File? = null
    private val handler = Handler(Looper.getMainLooper())
    private val rotate = object : Runnable {
        override fun run() {
            if (!recording) return
            stopRecorder()
            startRecorder()
            handler.postDelayed(this, CHUNK_MS)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (recording) return START_NOT_STICKY
        dir = File(intent?.getStringExtra("dir") ?: filesDir.absolutePath).apply { mkdirs() }
        startAsForeground()
        recording = true
        startedAt = System.currentTimeMillis()
        if (!startRecorder()) {
            recording = false
            stopSelf()
            return START_NOT_STICKY
        }
        handler.postDelayed(rotate, CHUNK_MS)
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(rotate)
        stopRecorder()
        recording = false
        super.onDestroy()
    }

    private fun startRecorder(): Boolean {
        val n = synchronized(parts) { parts.size } + 1
        val f = File(dir, "part_%03d.m4a".format(n))
        return try {
            val r = if (Build.VERSION.SDK_INT >= 31) MediaRecorder(this) else @Suppress("DEPRECATION") MediaRecorder()
            r.setAudioSource(MediaRecorder.AudioSource.MIC)
            r.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            r.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            r.setAudioChannels(1)
            r.setAudioSamplingRate(16000)
            r.setAudioEncodingBitRate(32000)
            r.setOutputFile(f.absolutePath)
            r.prepare()
            r.start()
            recorder = r
            synchronized(parts) { parts.add(f.absolutePath) }
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun stopRecorder() {
        recorder?.let {
            runCatching { it.stop() }
            runCatching { it.release() }
        }
        recorder = null
    }

    private fun startAsForeground() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= 26) {
            nm.createNotificationChannel(
                NotificationChannel("recording", "Recording", NotificationManager.IMPORTANCE_LOW).apply {
                    description = "Shown while a meeting or voice note is being recorded"
                }
            )
        }
        val open = PendingIntent.getActivity(
            this, 3,
            Intent(this, MainActivity::class.java).putExtra("route", "/meetings").addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val n: Notification = (if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, "recording") else @Suppress("DEPRECATION") Notification.Builder(this))
            .setSmallIcon(R.drawable.ic_stat_nizam)
            .setContentTitle("● $label")
            .setContentText("Recording · tap to open and stop")
            .setUsesChronometer(true)
            .setWhen(System.currentTimeMillis())
            .setContentIntent(open)
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= 30) {
            startForeground(78, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE)
        } else {
            startForeground(78, n)
        }
    }
}
