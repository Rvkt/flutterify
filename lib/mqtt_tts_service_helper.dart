import 'package:flutter/services.dart';

class MqttTtsServiceHelper {
  static const _channel = MethodChannel('mqtt_service_channel');

  static Future<bool> isServiceRunning() async {
    try {
      final bool result = await _channel.invokeMethod('isServiceRunning');
      return result;
    } catch (e) {
      print("Error checking service: $e");
      return false;
    }
  }
}
