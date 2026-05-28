import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
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
          initialRoute: sermonProvider.user != null ? '/navigation' : '/login',
          routes: {
            '/login': (context) => const LoginPage(),
            '/navigation': (context) => const MainNavigationPage(),
            '/live': (context) => const LiveTranslationPage(),
          },
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
        );
      },
    );
  }
}
