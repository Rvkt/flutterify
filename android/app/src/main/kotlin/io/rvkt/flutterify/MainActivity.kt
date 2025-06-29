package io.rvkt.flutterify

import android.app.ActivityManager
import android.content.*
import android.os.*
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.rvkt.flutterify.services.MqttTtsService

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mqtt_service_channel"

    private var mqttService: MqttTtsService? = null
    private var isBound = false

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName, binder: IBinder) {
            val localBinder = binder as MqttTtsService.LocalBinder
            mqttService = localBinder.getService()
            isBound = true
        }

        override fun onServiceDisconnected(name: ComponentName) {
            mqttService = null
            isBound = false
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ Start and bind service
        val serviceIntent = Intent(this, MqttTtsService::class.java)
        ContextCompat.startForegroundService(this, serviceIntent)
        bindService(serviceIntent, serviceConnection, Context.BIND_AUTO_CREATE)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isBound) {
            unbindService(serviceConnection)
            isBound = false
        }
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

                "subscribeToTopic" -> {
                    val topic = call.argument<String>("topic")
                    if (mqttService != null && isBound && topic != null) {
                        mqttService?.subscribeToTopic(topic)
                        result.success(true)
                    } else {
                        result.error("SERVICE_NOT_BOUND", "Service not bound or topic null", null)
                    }
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
