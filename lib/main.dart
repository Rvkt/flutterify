import 'package:flutter/material.dart';
import 'package:flutterify/core/main_app.dart';
import 'package:flutterify/injection/injection_container.dart';
import 'package:permission_handler/permission_handler.dart'; // 👈 Import this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init(); // Your DI setup or initial logic

  // ✅ Request POST_NOTIFICATIONS permission for Android 13+
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  runApp(const MainApp());
}
