import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/sermon_provider.dart';

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
    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        final sermonProvider = Provider.of<SermonProvider>(
          context,
          listen: false,
        );
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
    return Scaffold(
      backgroundColor: Colors.white, // Sleek premium clean white background
      body: SafeArea(
        child: Stack(
          children: [
            // Subtly textured background graphics inspired by Shrine
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2F69F8).withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2F69F8).withOpacity(0.03),
                ),
              ),
            ),

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
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEBF2FF),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2F69F8).withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons
                              .insights_rounded, // Brain/Wisdom/AI matching emblem
                          size: 44,
                          color: Color(0xFF2F69F8),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Logo Text
                      const Text(
                        'HISpeak',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: 1.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Premium Subtext
                      const Text(
                        '지혜롭고 영감 있는 실시간 예배 번역기',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
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
                            color: Color(0xFF2F69F8),
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
                    color: const Color(0xFF94A3B8).withOpacity(0.7),
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
