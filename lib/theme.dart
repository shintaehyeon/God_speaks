import 'package:flutter/material.dart';
import 'dart:ui';

class HISpeakTheme {
  // Main color palette matching the requested lavender tone & manner
  static const Color purpleMain = Color(0xFF8B5CF6);
  static const Color lightPurple = Color(0xFFC4B5FD);
  static const Color bgLavender = Color(0xFFF3F0FF);
  
  // Adaptive iridescent background stack (Dark/Light mode aware)
  static Widget buildIridescentBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          color: isDark ? const Color(0xFF0D061E) : const Color(0xFFF5F3FF), // Dynamic base color
        ),
        // Iridescent blurry blobs
        Positioned(
          top: -100,
          right: -50,
          child: _blurCircle(
            400,
            isDark
                ? const Color(0xFFEC4899).withOpacity(0.15)
                : const Color(0xFFFBCFE8).withOpacity(0.65), // Glowing Pink / Pastel Pink
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: _blurCircle(
            500,
            isDark
                ? const Color(0xFF3B82F6).withOpacity(0.15)
                : const Color(0xFFBFDBFE).withOpacity(0.70), // Glowing Blue / Pastel Blue
          ),
        ),
        Positioned(
          top: 200,
          left: 50,
          child: _blurCircle(
            350,
            isDark
                ? const Color(0xFF8B5CF6).withOpacity(0.20)
                : const Color(0xFFDDD6FE).withOpacity(0.75), // Glowing Lavender / Pastel Lavender
          ),
        ),
        Positioned(
          bottom: -80,
          right: -80,
          child: _blurCircle(
            350,
            isDark
                ? const Color(0xFFC4B5FD).withOpacity(0.18)
                : const Color(0xFFE5DEFF).withOpacity(0.60), // Glowing Purple / Pastel Purple
          ),
        ),
      ],
    );
  }

  static Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

// Reusable Premium Glassmorphic Card (Dark/Light mode aware)
class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const PremiumGlassCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withOpacity(0.5)
                : Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
