package com.example.app_scheduler

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the platform channel plugin so that
        // MethodChannel('com.yourapp/scheduler') calls from Dart
        // are routed to SchedulerPlugin.onMethodCall()
        flutterEngine.plugins.add(SchedulerPlugin())
    }
}