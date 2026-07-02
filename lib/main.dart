import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

// Provides global state for the ThemeMode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MindCareApp());
}

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'MindCare',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: LoginScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
