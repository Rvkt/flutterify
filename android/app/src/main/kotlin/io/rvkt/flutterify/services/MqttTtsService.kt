package io.rvkt.flutterify.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.speech.tts.TextToSpeech
import android.util.Log
import androidx.core.app.NotificationCompat
import org.eclipse.paho.client.mqttv3.*
import java.util.*
import java.util.concurrent.Executors
import javax.net.ssl.*

import java.security.SecureRandom
import java.security.cert.X509Certificate
import javax.net.ssl.SSLContext
import javax.net.ssl.SSLSocketFactory
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager


class MqttTtsService : Service(), TextToSpeech.OnInitListener {

    private lateinit var mqttClient: MqttClient
    private var tts: TextToSpeech? = null
    private val executor = Executors.newSingleThreadExecutor()

    // HiveMQ Cloud credentials
    private val serverUri = "ssl://367d365ff9c7477988364a43816f637d.s1.eu.hivemq.cloud:8883"
    private val username = "coderkamlesh"
    private val password = "Coder@mqtt3kamlesh#"
    private val defaultTopic = "test/flutter"

    override fun onCreate() {
        super.onCreate()
        startForegroundService()
        tts = TextToSpeech(this, this)
        setupMqttClient()
    }

    /**
     * Starts the service as a foreground service with a persistent notification
     */
    private fun startForegroundService() {
        val channelId = "mqtt_service_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "MQTT TTS Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("MQTT Service Running")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()

        startForeground(1, notification)
    }

    /**
     * Setup and connect the MQTT client to the broker with SSL and custom trust manager.
     */
    private fun setupMqttClient() {
        executor.execute {
            try {
                val clientId = "androidClient_${System.currentTimeMillis()}"
                mqttClient = MqttClient(serverUri, clientId, null)

                val options = MqttConnectOptions().apply {
                    isCleanSession = true
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
                        Log.d("MQTT", "Message received: $msg")
                        tts?.speak(msg, TextToSpeech.QUEUE_FLUSH, null, null)
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

    /**
     * Subscribe to a topic (default or custom).
     */
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

    /**
     * Creates an "unsafe" SSL Socket Factory that trusts all certificates.
     * ⚠️ Use only for development. DO NOT use in production!
     */
    private fun getUnsafeSSLSocketFactory(): SSLSocketFactory {
        val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
            override fun checkClientTrusted(
                chain: Array<X509Certificate>, authType: String
            ) {
            }

            override fun checkServerTrusted(
                chain: Array<X509Certificate>, authType: String
            ) {
            }

            override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
        })

        val sslContext = SSLContext.getInstance("TLS")
        sslContext.init(null, trustAllCerts, SecureRandom())
        return sslContext.socketFactory
    }

    /**
     * Initialize TTS engine.
     */
    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val result = tts?.setLanguage(Locale.US)
            if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
                Log.e("TTS", "Language not supported")
            }
        } else {
            Log.e("TTS", "TTS Init failed")
            val installIntent = Intent()
            installIntent.action = TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA
            installIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(installIntent)
        }
    }
    

    override fun onBind(intent: Intent?): IBinder? = null

    /**
     * Cleanup when service is destroyed.
     */
    override fun onDestroy() {
        executor.execute {
            try {
                if (mqttClient.isConnected) mqttClient.disconnect()
            } catch (e: MqttException) {
                Log.e("MQTT", "Disconnect failed: ${e.message}")
            }
        }
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
