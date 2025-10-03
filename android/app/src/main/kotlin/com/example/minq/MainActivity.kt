package com.example.minq

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "miinq/live_activity").setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    Log.d("MiinQ", "Live activity start: ${call.arguments}")
                    result.success(null)
                }
                "update" -> {
                    Log.d("MiinQ", "Live activity update: ${call.arguments}")
                    result.success(null)
                }
                "end" -> {
                    Log.d("MiinQ", "Live activity end: ${call.arguments}")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "miinq/wearables").setMethodCallHandler { call, result ->
            when (call.method) {
                "syncSnapshot" -> {
                    Log.d("MiinQ", "Wearable snapshot: ${call.arguments}")
                    result.success(null)
                }
                "registerQuickAction" -> {
                    Log.d("MiinQ", "Wearable quick action: ${call.arguments}")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "miinq/fitness_bridge").setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(true)
                "fetchDailySteps" -> result.success(7500)
                "syncHabitCompletion" -> {
                    Log.d("MiinQ", "Fitness sync: ${call.arguments}")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
