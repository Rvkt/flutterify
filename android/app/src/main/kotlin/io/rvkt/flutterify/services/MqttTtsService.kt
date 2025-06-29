package io.rvkt.flutterify.services

import android.app.*
import android.content.*
import android.graphics.BitmapFactory
import android.media.AudioManager
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import io.rvkt.flutterify.R
import io.rvkt.flutterify.MainActivity
import io.rvkt.flutterify.utils.TtsSpeaker
import org.eclipse.paho.client.mqttv3.*
import org.json.JSONObject
import java.security.SecureRandom
import java.security.cert.X509Certificate
import java.util.concurrent.Executors
import javax.net.ssl.*

class MqttTtsService : Service() {

    private lateinit var mqttClient: MqttClient
    private lateinit var ttsSpeaker: TtsSpeaker
    private val executor = Executors.newSingleThreadExecutor()

    // HiveMQ Cloud credentials
    private val serverUri = "ssl://367d365ff9c7477988364a43816f637d.s1.eu.hivemq.cloud:8883"
    private val username = "coderkamlesh"
    private val password = "Coder@mqtt3kamlesh#"
    private val defaultTopic = "flashmart"

    // Binder to allow MainActivity to call public methods
    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): MqttTtsService = this@MqttTtsService
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }

    override fun onCreate() {
        super.onCreate()
        startForegroundService()
        ttsSpeaker = TtsSpeaker(this, languageCode = getLanguage())
        setupMqttClient()
    }

    private fun startForegroundService() {
        val channelId = "background_service_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Default",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps your app updated in the background."
                setShowBadge(false)
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Staying Connected")
            .setContentText("Your app is receiving updates in real time.")
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()

        startForeground(1, notification)
    }

    private fun setupMqttClient() {
        executor.execute {
            try {
                val clientId = "androidClient_${System.currentTimeMillis()}"
                mqttClient = MqttClient(serverUri, clientId, null)

                val options = MqttConnectOptions().apply {
                    isCleanSession = false
                    userName = username
                    keepAliveInterval = 60
                    password = this@MqttTtsService.password.toCharArray()
                    isAutomaticReconnect = true
                    socketFactory = getUnsafeSSLSocketFactory()
                }

                mqttClient.setCallback(object : MqttCallback {
                    override fun connectionLost(cause: Throwable?) {
                        Log.e("MQTT", "Connection lost: ${cause?.message}")
                    }

                    override fun messageArrived(topic: String?, message: MqttMessage?) {
                        val msg = message.toString()

                        val json = JSONObject(msg)
                        val map = mutableMapOf<String, String>()
                        json.keys().forEach { key -> map[key] = json.getString(key) }

                        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                        audioManager.setStreamVolume(
                            AudioManager.STREAM_MUSIC,
                            audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC),
                            0
                        )

                        Log.d("MQTT", "Message received: $msg")
                        val body = map["body"] ?: "You have received a new update."
                        ttsSpeaker.speak(body)
                        showLocalNotification(map)
                    }

                    override fun deliveryComplete(token: IMqttDeliveryToken?) {}
                })

                mqttClient.connect(options)
                Log.d("MQTT", "Connected to HiveMQ")
                subscribeToTopic(defaultTopic)

            } catch (e: MqttException) {
                Log.e("MQTT", "MQTT setup failed: $e")
            }
        }
    }

    fun subscribeToTopic(topic: String, qos: Int = 1) {
        executor.execute {
            try {
                if (mqttClient.isConnected) {
                    mqttClient.subscribe(topic, qos)
                    Log.d("MQTT", "Subscribed to $topic")
                } else {
                    Log.e("MQTT", "MQTT not connected. Can't subscribe to $topic")
                }
            } catch (e: MqttException) {
                Log.e("MQTT", "Subscribe failed: ${e.message}")
            }
        }
    }

    private fun showLocalNotification(message: Map<String, String>) {
        val channelId = "mqtt_message_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Orders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Shows real-time information about new orders"
                enableLights(true)
                enableVibration(true)
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notificationId = System.currentTimeMillis().toInt()
        val bigPicture = BitmapFactory.decodeResource(resources, R.drawable.bg)
        val title = message["title"] ?: "New Order"
        val body = message["body"] ?: "You have received a new update."

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(
                NotificationCompat.BigPictureStyle()
                    .bigPicture(bigPicture)
                    .setSummaryText(body)
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId, notification)
    }

    private fun getUnsafeSSLSocketFactory(): SSLSocketFactory {
        val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
            override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {}
            override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {}
            override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
        })

        val sslContext = SSLContext.getInstance("TLS")
        sslContext.init(null, trustAllCerts, SecureRandom())
        return sslContext.socketFactory
    }

    private fun getLanguage(): String {
        return "hi" // or "en", "bn", etc.
    }

    override fun onDestroy() {
        executor.execute {
            try {
                if (mqttClient.isConnected) mqttClient.disconnect()
            } catch (e: MqttException) {
                Log.e("MQTT", "Disconnect failed: ${e.message}")
            }
        }
        ttsSpeaker.stop()
        ttsSpeaker.shutdown()
        super.onDestroy()
    }
}
