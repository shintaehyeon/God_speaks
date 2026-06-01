import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/sermon_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: sermonProvider.userRole.contains("👑") 
                    ? const Color(0xFFFEF3C7) 
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: sermonProvider.userRole.contains("👑") 
                      ? const Color(0xFFF59E0B) 
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Text(
                sermonProvider.userRole.contains("👑") ? '👑 Premium' : 'Guest',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: sermonProvider.userRole.contains("👑") 
                      ? const Color(0xFFB45309) 
                      : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ),
        leadingWidth: 72,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mic_none_rounded,
              color: Color(0xFF2F69F8),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              '실시간 예배 준비 완료',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        actions: [
          // Language selector chip
          GestureDetector(
            onTap: () {
              sermonProvider.toggleLanguageDirection();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(sermonProvider.isEnglishToKorean
                      ? '번역 방향: English ➔ 한국어 변경됨'
                      : '번역 방향: 한국어 ➔ English 변경됨'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    sermonProvider.isEnglishToKorean ? '🇺🇸 EN ➔ 🇰🇷 KR' : '🇰🇷 KR ➔ 🇺🇸 EN',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F69F8),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Re-branded Tutorial Mode Banner
              GestureDetector(
                onTap: () {
                  sermonProvider.toggleRealAI(!sermonProvider.useRealAI);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(sermonProvider.useRealAI
                          ? '실시간 AI 마이크 번역 모드가 활성화되었습니다!'
                          : '처음 사용자용 스마트 가이드/튜토리얼 모드가 활성화되었습니다!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? (sermonProvider.useRealAI ? const Color(0xFF1E293B) : const Color(0xFF2D1B2D))
                        : (sermonProvider.useRealAI ? const Color(0xFFEFF6FF) : const Color(0xFFFDF2F8)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sermonProvider.useRealAI ? const Color(0xFFBFDBFE) : const Color(0xFFFBCFE8),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sermonProvider.useRealAI ? const Color(0xFF3B82F6) : const Color(0xFFEC4899),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          sermonProvider.useRealAI ? Icons.psychology_rounded : Icons.school_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sermonProvider.useRealAI ? '실시간 AI 마이크 모드 활성 중' : '🎓 처음 사용자 가이드 모드 활성 중',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? (sermonProvider.useRealAI ? const Color(0xFF93C5FD) : const Color(0xFFF472B6))
                                    : (sermonProvider.useRealAI ? const Color(0xFF1E3A8A) : const Color(0xFF831843)),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sermonProvider.useRealAI
                                  ? '실시간 마이크 입력과 Gemini를 번역에 사용합니다.'
                                  : '터치하면 모사 설교 튜토리얼을 구동해 가이드라인을 보여줍니다.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? (sermonProvider.useRealAI ? const Color(0xFF60A5FA) : const Color(0xFFF472B6))
                                    : (sermonProvider.useRealAI ? const Color(0xFF2563EB) : const Color(0xFFDB2777)),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: sermonProvider.useRealAI ? const Color(0xFF3B82F6) : const Color(0xFFEC4899),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),

              // Giant Blue Recording Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (sermonProvider.isGuestLimitExceeded) {
                      _showLimitExceededDialog(context);
                    } else {
                      sermonProvider.toggleRecording();
                      Navigator.pushNamed(context, '/live');
                    }
                  },
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2F69F8).withOpacity(0.12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2F69F8).withOpacity(0.08),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF2F69F8),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.contact_support_rounded, // Customized mic logo with people
                            size: 54,
                            color: Colors.white,
                          ),
                          SizedBox(height: 12),
                          Text(
                            '실시간 번역 시작하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Silent sound wave indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 3.5,
                    height: index % 2 == 0 ? 12 : 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F69F8).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // 1. Noise Cancellation Optimization Selector
              Text(
                '장소 최적화 (NOISE CANCELLATION)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildLocationChip(context, '본당', sermonProvider),
                  const SizedBox(width: 8),
                  _buildLocationChip(context, '한동대학교 대강당', sermonProvider),
                  const SizedBox(width: 8),
                  _buildLocationChip(context, '소예배실', sermonProvider),
                ],
              ),

              const SizedBox(height: 28),

              // 2. Translation Mode Selector
              Text(
                '번역 모드',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildModeButton(context, '자막 모드', sermonProvider),
                    _buildModeButton(context, '요약 모드', sermonProvider),
                    _buildModeButton(context, '인용 추출', sermonProvider),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationChip(
    BuildContext context,
    String name,
    SermonProvider provider,
  ) {
    final isSelected = provider.selectedLocation == name;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setLocation(name),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2F69F8) : const Color(0xFFE2E8F0).withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String modeName,
    SermonProvider provider,
  ) {
    final isSelected = provider.selectedTranslationMode == modeName;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setTranslationMode(modeName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            modeName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF2F69F8) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  void _showLimitExceededDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text(
                '무료 체험 만료 🔒',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '일반 게스트 무료 체험 기회(최대 5회)를 모두 소진하셨습니다!\n\n간단한 구글 소셜 로그인만 진행하시면 평생 무제한 실시간 번역 자막 감상 및 Gemini AI 설교 챗봇 혜택을 100% 무료로 계속 사용하실 수 있습니다. 👑',
                style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('나중에', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('우측 하단 "설정" 탭으로 이동하여 로그아웃 후 다시 구글 로그인을 진행해 주세요!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F69F8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('로그인하러 가기 👑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
