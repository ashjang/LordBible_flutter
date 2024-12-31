package com.ashjang.lordbible.lord_bible

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import android.content.SharedPreferences
import es.antonborri.home_widget.HomeWidgetLaunchIntent

/**
 * Implementation of App Widget functionality.
 */
class BibleWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.bible_widget).apply {
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                val newWidgetText1 = widgetData.getString("title", "words")
                val newWidgetText2 = widgetData.getString("description", "Please select words from app")
                setTextViewText(R.id.appwidget_title, newWidgetText1)
                setTextViewText(R.id.appwidget_description, newWidgetText2)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)

        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

