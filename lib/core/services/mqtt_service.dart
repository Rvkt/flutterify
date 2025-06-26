import 'package:flutter/services.dart';

class MqttServiceController {
  static const platform = MethodChannel('mqtt_service_channel');

  static Future<void> startService() async {
    try {
      await platform.invokeMethod('startMqttService');
    } catch (e) {
      print('Failed to start MQTT service: $e');
    }
  }
}
