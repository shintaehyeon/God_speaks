import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/sermon_provider.dart';
import 'theme.dart';
import 'l10n/hispeak_localizations.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Premium Logo Fade & Zoom Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // 2. Timer-based Routing Transition to main/login screen
    Timer(const Duration(milliseconds: 2800), () async {
      if (mounted) {
        final sermonProvider = Provider.of<SermonProvider>(
          context,
          listen: false,
        );

        // [VIDEO RECORDING MODE] Force sign out on every startup
        // so the login screen and animations always appear!
        await sermonProvider.signOut();

        if (sermonProvider.user != null) {
          Navigator.pushReplacementNamed(context, '/navigation');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          HISpeakTheme.buildIridescentBg(context),
          SafeArea(
            child: Stack(
              children: [
                // Centered Animated Branding Content
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // HISpeak emblem
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: HISpeakTheme.purpleMain.withOpacity(
                                    isDark ? 0.35 : 0.15,
                                  ),
                                  blurRadius: 28,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.asset(
                                'assets/hispeak_clean_logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // App Logo Text
                          Text(
                            'HISpeak',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                              letterSpacing: 1.5,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Premium Subtext
                          Text(
                            context.l10n.t('splashSubtitle'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF64748B),
                              letterSpacing: 0.5,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Premium Progress Indicator
                          SizedBox(
                            width: 48,
                            height: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const LinearProgressIndicator(
                                color: HISpeakTheme.purpleMain,
                                backgroundColor: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Brand Signature
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'POWERED BY GOD SPEAKS AI ENGINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF94A3B8).withOpacity(0.6)
                            : const Color(0xFF64748B).withOpacity(0.8),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
