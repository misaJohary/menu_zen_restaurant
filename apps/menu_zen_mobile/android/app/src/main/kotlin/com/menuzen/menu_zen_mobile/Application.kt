package com.menuzen.menu_zen_mobile

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

class Application : Application() {
    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannels()
        }
    }

    private fun createNotificationChannels() {
        val manager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Silent persistent channel for the foreground service notification.
        NotificationChannel(
            "menu_zen_service",
            "Service Menu Zen",
            NotificationManager.IMPORTANCE_LOW,
        ).also { manager.createNotificationChannel(it) }

        // High-importance channel for order alerts (sound + heads-up).
        NotificationChannel(
            "menu_zen_orders",
            "Nouvelles commandes",
            NotificationManager.IMPORTANCE_HIGH,
        ).also { manager.createNotificationChannel(it) }
    }
}
