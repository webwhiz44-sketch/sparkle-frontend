import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  ApiClient.navigatorKey = navigatorKey;
  runApp(const SparkleApp());
}

class SparkleApp extends StatelessWidget {
  const SparkleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sparkle & Spill',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBE1373)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
