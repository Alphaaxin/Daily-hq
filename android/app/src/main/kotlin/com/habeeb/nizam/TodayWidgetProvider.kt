package com.habeeb.nizam

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.content.ComponentName

/** "Today" widget: streak, water, next prayer and the top open tasks. */
class TodayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val data = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        for (id in ids) {
            val v = RemoteViews(context.packageName, R.layout.widget_today)
            v.setTextViewText(R.id.w_streak, data.getString("w_streak", "🔥 0") ?: "🔥 0")
            v.setTextViewText(R.id.w_water, data.getString("w_water", "💧 0/8") ?: "")
            v.setTextViewText(R.id.w_prayer, data.getString("w_prayer", "") ?: "")
            v.setTextViewText(R.id.w_tasks, data.getString("w_tasks", "No open tasks") ?: "")
            v.setOnClickPendingIntent(R.id.w_root, open(context, "/today", 10))
            v.setOnClickPendingIntent(R.id.w_add_water, open(context, "/action/water", 11))
            manager.updateAppWidget(id, v)
        }
    }

    companion object {
        const val PREFS = "nizam_widgets"

        /** Saves fresh values from Flutter and redraws every Today widget. */
        fun push(ctx: Context, values: Map<String, String>) {
            val e = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            for ((k, v) in values) e.putString(k, v)
            e.apply()
            val mgr = AppWidgetManager.getInstance(ctx)
            val ids = mgr.getAppWidgetIds(ComponentName(ctx, TodayWidgetProvider::class.java))
            if (ids.isNotEmpty()) TodayWidgetProvider().onUpdate(ctx, mgr, ids)
        }

        fun open(ctx: Context, route: String, code: Int): PendingIntent = PendingIntent.getActivity(
            ctx, code,
            Intent(ctx, MainActivity::class.java).putExtra("route", route)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }
}
