package com.example.dot_final_year_project

import android.app.Activity
import android.app.ActivityManager
import android.content.Intent
import android.os.Bundle

class ShortcutActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val url = intent?.getStringExtra("url")
        val name = intent?.getStringExtra("name")

        val launchIntent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            putExtra("url", url)
            putExtra("name", name)
            addFlags(Intent.FLAG_ACTIVITY_NEW_DOCUMENT)
            addFlags(Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
        }

        startActivity(launchIntent)

        // Set the task name in Recent Apps
        if (name != null) {
            setTaskDescription(ActivityManager.TaskDescription(name))
        }

        finish()
    }
}
