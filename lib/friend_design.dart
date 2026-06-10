import 'package:flutter/material.dart';
import 'dart:ui';

// 디자인 가이드라인 색상
class HISpeakColor {
  static const Color primaryBlue = Color(0xFF2F69F8);
  static const Color bgDark = Color(0xFF0F172A);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color glassWhite = Colors.white12;
}

// 참고 이미지 스타일의 배경 (그라데이션)
Widget buildMysticBackground({required Widget child}) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFB4C6FF), // 연한 블루
          Color(0xFFE5D9F2), // 연한 보라 (이미지 느낌)
          Color(0xFFF5EEFB), 
        ],
      ),
    ),
    child: child,
  );
}

// 글래스모피즘 카드 위젯
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;

  const GlassCard({required this.child, this.blur = 15, this.opacity = 0.2});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

class LiveSermonScreen extends StatelessWidget {
  const LiveSermonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildMysticBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(child: _buildTranslationStream()),
              _buildRecordingSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.maybePop(context),
          ),
          Text("실시간 설교 번역", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: HISpeakColor.bgDark)),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationStream() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSpeechBubble("And God said, 'Let there be light.'", "그리고 하나님이 말씀하셨습니다. '빛이 있으라.'"),
        _buildSpeechBubble("And there was light.", "그러자 빛이 생겼습니다."),
      ],
    );
  }

  Widget _buildSpeechBubble(String en, String ko) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        opacity: 0.4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(en, style: const TextStyle(fontSize: 14, color: Colors.black45, fontStyle: FontStyle.italic)),
              const SizedBox(height: 6),
              Text(ko, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: HISpeakColor.bgDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          // 마이크 펄스 비주얼 (실제 개발 시 AnimationController 사용)
          GestureDetector(
            onTap: () {
              // Navigate to summary page so we can see the second screen too
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SermonSummaryScreen()),
              );
            },
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HISpeakColor.primaryBlue,
                boxShadow: [BoxShadow(color: HISpeakColor.primaryBlue.withOpacity(0.3), blurRadius: 20, spreadRadius: 10)],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 35),
            ),
          ),
          const SizedBox(height: 16),
          const Text("목소리를 분석하고 있습니다...", style: TextStyle(color: Colors.black45, fontSize: 13)),
        ],
      ),
    );
  }
}

class SermonSummaryScreen extends StatelessWidget {
  const SermonSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildMysticBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("오늘의 은혜 요약", style: TextStyle(color: HISpeakColor.bgDark)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildSummaryStep(1, "성경 말씀", "요한복음 1:1", Icons.auto_stories, true),
                    _buildSummaryStep(2, "핵심 메시지", "말씀이 곧 하나님이시니라", Icons.lightbulb, false),
                    _buildSummaryStep(3, "삶의 적용", "매일 아침 말씀으로 시작하기", Icons.check_circle, false),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStep(int step, String title, String content, IconData icon, bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        opacity: 0.6,
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          leading: CircleAvatar(
            backgroundColor: HISpeakColor.primaryBlue.withOpacity(0.1),
            child: Icon(icon, color: HISpeakColor.primaryBlue, size: 20),
          ),
          title: Text("STEP $step. $title", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: HISpeakColor.primaryBlue)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(content, style: const TextStyle(fontSize: 16, height: 1.5, color: HISpeakColor.bgDark)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
