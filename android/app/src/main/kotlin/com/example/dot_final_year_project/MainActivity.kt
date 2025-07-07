package com.example.dot_final_year_project

import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.yourapp/shortcut"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "createShortcut") {
                val name = call.argument<String>("name") ?: "WebApp"
                val url = call.argument<String>("url") ?: "https://example.com"
                val icon = call.argument<String>("icon") // get icon from Dart

                createShortcut(name, url,icon)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutter/intent")
            .setMethodCallHandler { call, result ->
                if (call.method == "getInitialIntent") {
                    val intent = intent
                    val url = intent.getStringExtra("url")
                    val name = intent.getStringExtra("name")
                    result.success(mapOf("url" to url, "name" to name))
                } else {
                    result.notImplemented()
                }
            }
    }

private fun createShortcut(name: String, url: String, iconName: String?) {
    val shortcutManager = getSystemService(ShortcutManager::class.java)

    val intent = Intent(this, ShortcutActivity::class.java).apply {
        action = Intent.ACTION_VIEW
        putExtra("url", url)
        putExtra("name", name)
    }

    val icon: Icon = if (iconName != null) {
        try {
            val assetManager = applicationContext.assets
            val inputStream = assetManager.open("icons/$iconName")
            val bitmap = android.graphics.BitmapFactory.decodeStream(inputStream)
            Icon.createWithBitmap(bitmap)
        } catch (e: Exception) {
            Icon.createWithResource(this, R.mipmap.ic_launcher) // fallback
        }
    } else {
        Icon.createWithResource(this, R.mipmap.ic_launcher)
    }

    val shortcut = ShortcutInfo.Builder(this, name)
        .setShortLabel(name)
        .setLongLabel(name)
        .setIcon(icon)
        .setIntent(intent)
        .build()

    shortcutManager?.requestPinShortcut(shortcut, null)
}

}
