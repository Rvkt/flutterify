package io.rvkt.flutterify

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.rvkt.flutterify.services.MqttTtsService

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mqtt_service_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ Auto-start MQTT service when app starts
        val serviceIntent = Intent(this, MqttTtsService::class.java)
        ContextCompat.startForegroundService(this, serviceIntent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMqttService" -> {
                    val serviceIntent = Intent(this, MqttTtsService::class.java)
                    ContextCompat.startForegroundService(this, serviceIntent)
                    result.success(null)
                }

                "isServiceRunning" -> {
                    val isRunning = isServiceRunning(MqttTtsService::class.java)
                    result.success(isRunning)
                }

                else -> result.notImplemented()
            }
        }
    }

    // 🔍 Utility function to check if service is running
    private fun isServiceRunning(serviceClass: Class<*>): Boolean {
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
            if (serviceClass.name == service.service.className) {
                return true
            }
        }
        return false
    }
}
