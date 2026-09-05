import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens/webview_screen.dart';

void main() => runApp(const SensorsHubApp());

class SensorsHubApp extends StatelessWidget {
  const SensorsHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: kAccentCyan),
      home: const WebViewScreen(),
    );
  }
}