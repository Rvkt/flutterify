import 'package:flutter/material.dart';
import 'package:flutterify/core/theme/app_theme.dart';

import '../features/products/presentation/screens/products_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: ProductsScreen(),
    );
  }
}
