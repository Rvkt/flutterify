package io.rvkt.flutterify.utils

import android.content.Context
import android.content.Intent
import android.os.Build
import android.speech.tts.TextToSpeech
import android.util.Log
import java.util.*

class TtsSpeaker(
    private val context: Context,
    private val languageCode: String = "hi", // default language code, can be customized
    private val speechRate: Float = 0.7f,
    private val pitch: Float = 1.0f
) : TextToSpeech.OnInitListener {

    private var tts: TextToSpeech? = null
    private var isInitialized = false

    init {
        tts = TextToSpeech(context, this)
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val locale = when (languageCode) {
                "hi" -> Locale("hi", "IN")
                "en" -> Locale("en", "US")
                "bn" -> Locale("bn", "IN")
                else -> Locale.getDefault()
            }

            val result = tts?.setLanguage(locale)
            tts?.setSpeechRate(speechRate)
            tts?.setPitch(pitch)

            // Try to set a male voice if available (API 21+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val maleVoice = tts?.voices?.find { voice ->
                    voice.locale == locale && voice.name.contains("male", ignoreCase = true)
                }
                if (maleVoice != null) {
                    tts?.voice = maleVoice
                    Log.d(TAG, "Male voice set: ${maleVoice.name}")
                } else {
                    Log.w(TAG, "No male voice found for locale $locale")
                }
            }

            if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
                Log.e(TAG, "Language not supported")
            } else {
                isInitialized = true
            }
        } else {
            Log.e(TAG, "TTS Init failed, starting install intent")
            val installIntent = Intent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA)
            installIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(installIntent)
        }
    }

    fun speak(text: String) {
        if (!isInitialized) {
            Log.w(TAG, "TTS not initialized yet, cannot speak")
            return
        }
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
    }

    fun stop() {
        tts?.stop()
    }

    fun shutdown() {
        tts?.shutdown()
    }

    companion object {
        private const val TAG = "TtsSpeaker"
    }
}
