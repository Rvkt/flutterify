import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const _channel = MethodChannel('mqtt_service_channel');

  bool _isServiceRunning = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    try {
      final bool result = await _channel.invokeMethod('isServiceRunning');
      setState(() {
        _isServiceRunning = result;
        _loading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isServiceRunning = false;
        _loading = false;
      });
    }
  }

  Future<void> _startService() async {
    try {
      await _channel.invokeMethod('startMqttService');
      setState(() {
        _isServiceRunning = true;
      });
    } catch (e) {
      print("Error starting service: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MQTT TTS Service")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isServiceRunning ? Icons.wifi : Icons.wifi_off,
                        color: _isServiceRunning ? Colors.green : Colors.red,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _isServiceRunning ? "Service is currently RUNNING" : "Service is currently STOPPED",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: const Text("Start MQTT TTS Service"),
                        value: _isServiceRunning,
                        onChanged: (val) {
                          if (!_isServiceRunning) {
                            _startService();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
