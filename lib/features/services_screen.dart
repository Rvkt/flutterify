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

  String? _selectedTopic;

  final List<String> _mqttTopics = [
    // Warehouse
    'app/warehouse/updates',
    'app/warehouse/inventory',
    'app/warehouse/orders/new',
    'app/warehouse/orders/packed',
    'app/warehouse/alerts',

    // Rider
    'app/rider/assignments',
    'app/rider/notifications',
    'app/rider/alerts',
    'app/rider/status/update',
    'app/rider/location/track',

    // Consumer
    'app/consumer/order/status',
    'app/consumer/promotions',
    'app/consumer/support/replies',
    'app/consumer/notifications',
    'app/consumer/order/delivered',
  ];

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

  Future<void> _subscribeToTopic(String topic) async {
    try {
      final success = await _channel.invokeMethod('subscribeToTopic', {
        'topic': topic,
      });
      print('Subscribed to topic: $success');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscribed to "$topic"')),
      );
    } catch (e) {
      print('Failed to subscribe to topic: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to subscribe to topic')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MQTT TTS Service")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
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
                  const SizedBox(height: 30),

                  /// MQTT Topic Dropdown
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Subscribe to Topic",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _selectedTopic,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Select Topic",
                            ),
                            items: _mqttTopics
                                .map((topic) => DropdownMenuItem(
                                      value: topic,
                                      child: Text(topic),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTopic = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.subscriptions),
                              label: const Text("Subscribe"),
                              onPressed: _selectedTopic == null ? null : () => _subscribeToTopic(_selectedTopic!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
