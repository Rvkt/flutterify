# --- AndroidX Core ---
-keep class androidx.core.app.CoreComponentFactory { *; }

# --- Logging Frameworks ---
# SLF4J (used by many libs including Paho MQTT optionally)
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**

# Java Util Logging (used by some Java libs)
-keep class java.util.logging.** { *; }
-dontwarn java.util.logging.**

# Apache Commons Logging (just in case)
-keep class org.apache.commons.logging.** { *; }

# --- MQTT / Eclipse Paho ---
-keep class org.eclipse.paho.** { *; }
-keep class android.speech.tts.** { *; }


