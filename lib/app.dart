import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'splash.dart';
import 'state/sermon_provider.dart';
import 'main_navigation.dart';
import 'live_translation.dart';

class SermonTranslatorApp extends StatelessWidget {
  const SermonTranslatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SermonProvider>(
      builder: (context, sermonProvider, _) {
        return MaterialApp(
          title: 'Smart Sermon Translator',
          debugShowCheckedModeBanner: false,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/navigation': (context) => const MainNavigationPage(),
            '/live': (context) => const LiveTranslationPage(),
          },
          themeMode: _parseThemeMode(sermonProvider.appearance),
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: const Color(0xFF2F69F8), // Sleek electric blue
            scaffoldBackgroundColor: const Color(0xFFF8F9FB), // Modern clean off-white
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F69F8),
              primary: const Color(0xFF2F69F8),
              secondary: const Color(0xFFEBF2FF),
              background: const Color(0xFFF8F9FB),
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                side: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1E293B),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              iconTheme: IconThemeData(color: Color(0xFF64748B)),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF2F69F8),
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Premium Dark Slate/Navy
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF2F69F8),
              primary: const Color(0xFF2F69F8),
              secondary: const Color(0xFF1E293B),
              background: const Color(0xFF0F172A),
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF1E293B),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                side: BorderSide(color: Color(0xFF334155), width: 1),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              foregroundColor: Color(0xFFF1F5F9),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1F5F9),
              ),
              iconTheme: IconThemeData(color: Color(0xFF94A3B8)),
            ),
          ),
        );
      },
    );
  }

  ThemeMode _parseThemeMode(String appearance) {
    switch (appearance) {
      case 'Light Mode':
        return ThemeMode.light;
      case 'Dark Mode':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
