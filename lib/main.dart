import 'package:flutter/material.dart';
import 'package:flutterify/core/main_app.dart';
import 'package:flutterify/injection/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init(); // <<< This must be called before runApp()
  runApp(const MainApp());
}
