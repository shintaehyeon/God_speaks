import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'splash.dart';
import 'state/sermon_provider.dart';
import 'main_navigation.dart';
import 'live_translation.dart';
import 'archive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/hispeak_localizations.dart';

class SermonTranslatorApp extends StatelessWidget {
  const SermonTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SermonProvider>(
      builder: (context, sermonProvider, _) {
        return MaterialApp(
          title: 'HISpeak',
          debugShowCheckedModeBanner: false,
          locale: Locale(sermonProvider.appLanguageCode),
          supportedLocales: HISpeakLocalizations.supportedLocales,
          localizationsDelegates: const [
            HISpeakLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/navigation': (context) => const MainNavigationPage(),
            '/live': (context) => const LiveTranslationPage(),
            '/archive': (context) => const ArchivePage(),
          },
          themeMode: _parseThemeMode(sermonProvider.appearance),
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            primaryColor: const Color(0xFF8B5CF6), // Sleek royal lavender
            scaffoldBackgroundColor: const Color(
              0xFFF5F3FF,
            ), // Bright lavender-white
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color(0xFF8B5CF6),
              primary: const Color(0xFF8B5CF6),
              secondary: const Color(0xFFE5DEFF),
              background: const Color(0xFFF5F3FF),
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                side: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(
                0xFFEDE9FE,
              ), // Soft light lavender background for status/appbar distinction
              foregroundColor: Color(0xFF1E293B),
              elevation: 0,
              centerTitle: true,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
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
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            primaryColor: const Color(0xFF8B5CF6),
            scaffoldBackgroundColor: const Color(
              0xFF0D061E,
            ), // Premium deep royal purple
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF8B5CF6),
              primary: const Color(0xFF8B5CF6),
              secondary: const Color(0xFF1E1B4B),
              background: const Color(0xFF0D061E),
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
              backgroundColor: Color(
                0xFF160E2E,
              ), // Deep purple background for status/appbar distinction
              foregroundColor: Color(0xFFF1F5F9),
              elevation: 0,
              centerTitle: true,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
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
