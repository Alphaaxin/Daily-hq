package com.habeeb.nizam

import android.content.Intent

/** Things the app was opened with: a route (widgets, notifications) or shared text (Google Maps share). */
object LaunchData {
    private var route: String? = null
    private var text: String? = null

    fun capture(intent: Intent?) {
        if (intent == null) return
        intent.getStringExtra("route")?.let { route = it }
        if (intent.action == Intent.ACTION_SEND && intent.type?.startsWith("text/") == true) {
            val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT)
            val body = intent.getStringExtra(Intent.EXTRA_TEXT)
            text = listOfNotNull(subject, body).joinToString("\n")
            route = "/leads/new"
        }
    }

    fun take(): Map<String, String?> {
        val m = mapOf("route" to route, "text" to text)
        route = null
        text = null
        return m
    }

    fun hasData() = route != null || text != null
}
