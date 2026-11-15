package com.habeeb.nizam

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

/** One-tap "Record meeting" widget. */
class RecordWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            val v = RemoteViews(context.packageName, R.layout.widget_record)
            v.setOnClickPendingIntent(R.id.widget_root, TodayWidgetProvider.open(context, "/meetings/record", 12))
            manager.updateAppWidget(id, v)
        }
    }
}
