import 'package:ai_es/ai_provider.dart';
import 'package:ai_es/local_host_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final themeProvider = ThemeProvider();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => aiProvider),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize speech recognition
    context.read<AIAssistantProvider>().initializeSpeech();

    // Watch theme changes
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Ai Assistant',
      theme: themeProvider.themeData,
      debugShowCheckedModeBanner: false,
      home: const VoiceControlScreen(),
    );
  }
}

//lets create a theme provider here for selecting the color scheme and dark mode

// theme_provider.dart

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;
  Color primaryColor = Colors.deepPurple;

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      fontFamily: 'Segoe UI',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontFamily: 'Segoe UI, Arial, sans-serif',
        ),
      ),
    );
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void updatePrimaryColor(Color color) {
    primaryColor = color;
    notifyListeners();
  }
}
