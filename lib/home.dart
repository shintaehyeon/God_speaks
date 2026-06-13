import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import 'state/sermon_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'theme.dart';
import 'edit_summary_sheet.dart';
import 'models/saved_item.dart';
import 'dart:async';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        leadingWidth: 72,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mic_none_rounded,
              color: HISpeakTheme.purpleMain,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '실시간 예배 준비 완료',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155),
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
                  content: Text(
                    sermonProvider.isEnglishToKorean
                        ? '번역 방향: English ➔ 한국어 변경됨'
                        : '번역 방향: 한국어 ➔ English 변경됨',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    sermonProvider.isEnglishToKorean
                        ? '🇺🇸 EN ➔ 🇰🇷 KR'
                        : '🇰🇷 KR ➔ 🇺🇸 EN',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: HISpeakTheme.purpleMain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          HISpeakTheme.buildIridescentBg(context),
          SafeArea(
            child: Column(
              children: [
                if (sermonProvider.isOffline)
                  Container(
                    color: Colors.amber[800],
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: const [
                        Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '네트워크 미연결: 안전 시뮬레이터 모드로 동작합니다.',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    // Beautiful illustration slider using local premium asset & archived items
                    ArchivedVersesSlider(
                      items: sermonProvider.archiveItems
                          .where((item) => sermonProvider.savedItemIds.contains(item.id))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // 1. Re-branded Tutorial Mode Banner
                    GestureDetector(
                onTap: () {
                  sermonProvider.toggleRealAI(!sermonProvider.useRealAI);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        sermonProvider.useRealAI
                            ? '실시간 AI 마이크 번역 모드가 활성화되었습니다!'
                            : '처음 사용자용 스마트 가이드/튜토리얼 모드가 활성화되었습니다!',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: PremiumGlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sermonProvider.useRealAI
                              ? HISpeakTheme.purpleMain
                              : const Color(0xFFEC4899),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          sermonProvider.useRealAI
                              ? Icons.psychology_rounded
                              : Icons.school_rounded,
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
                              sermonProvider.useRealAI
                                  ? '실시간 AI 마이크 모드 활성 중'
                                  : '🎓 처음 사용자 가이드 모드 활성 중',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? (sermonProvider.useRealAI
                                          ? const Color(0xFFC4B5FD)
                                          : const Color(0xFFF472B6))
                                    : (sermonProvider.useRealAI
                                          ? HISpeakTheme.purpleMain
                                          : const Color(0xFF831843)),
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
                                    ? (sermonProvider.useRealAI
                                          ? const Color(0xFFA78BFA)
                                          : const Color(0xFFF472B6))
                                    : (sermonProvider.useRealAI
                                          ? const Color(0xFF7C3AED)
                                          : const Color(0xFFDB2777)),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: sermonProvider.useRealAI
                            ? HISpeakTheme.purpleMain
                            : const Color(0xFFEC4899),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (sermonProvider.hasTodaySermonSummary) ...[
                const SizedBox(height: 16),
                _buildTodaySermonSummaryCard(context, sermonProvider),
              ],
              const SizedBox(height: 24),

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
                      color: HISpeakTheme.purpleMain.withOpacity(0.12),
                      boxShadow: [
                        BoxShadow(
                          color: HISpeakTheme.purpleMain.withOpacity(0.08),
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
                          colors: [HISpeakTheme.lightPurple, HISpeakTheme.purpleMain],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _CrossIcon(
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

              const SizedBox(height: 24),

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
                      color: HISpeakTheme.purpleMain.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
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
    ],
  ),
),
    ],
  ),
    );
  }

  Widget _buildTodaySermonSummaryCard(BuildContext context, SermonProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Fallback if structured data is empty
    if (provider.todaySermonTitle.isEmpty) {
      final transcript = provider.todaySermonTranscript.trim();
      final preview = transcript.length > 220
          ? "${transcript.substring(0, 220)}..."
          : transcript;

      return PremiumGlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.summarize_rounded, color: Color(0xFF2F69F8), size: 20),
                const SizedBox(width: 8),
                Text(
                  '오늘의 설교 요약',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            MarkdownBody(
              data: provider.todaySermonSummary,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
                strong: TextStyle(
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                ),
                listBullet: const TextStyle(
                  color: Color(0xFF2F69F8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  preview,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              '지난 요약본에도 자동 저장됨',
              style: TextStyle(
                color: Color(0xFF2F69F8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Premium structured UI
    return PremiumGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: HISpeakTheme.purpleMain, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    '오늘의 설교 분석',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (provider.todaySermonCategory.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.todaySermonCategory,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: HISpeakTheme.purpleMain,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Title / Main Topic
          Text(
            provider.todaySermonTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Key Scripture & Parallel Verse Container
          if (provider.todaySermonKeyScripture.isNotEmpty) ...[
            Text(
              '📖 관련 성경 본문',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.todaySermonKeyScripture,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                    ),
                  ),
                  if (provider.todaySermonKeyScriptureTextKor.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      provider.todaySermonKeyScriptureTextKor,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (provider.todaySermonKeyScriptureTextEng.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      provider.todaySermonKeyScriptureTextEng,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Sermon Summary Bullet Points
          if (provider.todaySermonBulletPoints.isNotEmpty) ...[
            Text(
              '💡 핵심 요약',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            ...provider.todaySermonBulletPoints.map((pt) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: HISpeakTheme.purpleMain, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      pt,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],

          // Application Points
          if (provider.todaySermonApplicationPoints.isNotEmpty) ...[
            Text(
              '🏃 삶의 적용점',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            ...provider.todaySermonApplicationPoints.map((pt) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pt,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],

          // Prayer Points
          if (provider.todaySermonPrayerPoints.isNotEmpty) ...[
            Text(
              '🙏 기도 제목',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            ...provider.todaySermonPrayerPoints.map((pt) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFEC4899)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pt,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

        if (provider.todaySermonUserComment.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E38) : const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF3B2E5C) : const Color(0xFFE5DEFF),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: HISpeakTheme.purpleMain, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '✍️ 나의 묵상 메모',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  provider.todaySermonUserComment,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
                    height: 1.45,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),
        Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFF1F5F9)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => EditSummarySheet(
                    summaryId: provider.todaySummaryDocId,
                    initialBulletPoints: provider.todaySermonBulletPoints,
                    initialApplicationPoints: provider.todaySermonApplicationPoints,
                    initialPrayerPoints: provider.todaySermonPrayerPoints,
                    initialUserComment: provider.todaySermonUserComment,
                  ),
                );
              },
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text(
                '수정 / 코멘트 추가',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: HISpeakTheme.purpleMain,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Text(
              '지난 요약본에도 자동 저장됨',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(
    BuildContext context,
    String name,
    SermonProvider provider,
  ) {
    final isSelected = provider.selectedLocation == name;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setLocation(name),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? HISpeakTheme.purpleMain
                : (isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? HISpeakTheme.purpleMain
                  : (isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.5)),
              width: 1.5,
            ),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setTranslationMode(modeName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                : Colors.transparent,
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
              color: isSelected
                  ? HISpeakTheme.purpleMain
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '나중에',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '우측 하단 "설정" 탭으로 이동하여 로그아웃 후 다시 구글 로그인을 진행해 주세요!',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HISpeakTheme.purpleMain,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '로그인하러 가기 👑',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ShimmerPlaceholder extends StatefulWidget {
  const ShimmerPlaceholder({Key? key}) : super(key: key);

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// Interactive Auto-Sliding Archived Verses/Quotes Slider Component
class ArchivedVersesSlider extends StatefulWidget {
  final List<SavedItem> items;

  const ArchivedVersesSlider({Key? key, required this.items}) : super(key: key);

  @override
  State<ArchivedVersesSlider> createState() => _ArchivedVersesSliderState();
}

class _ArchivedVersesSliderState extends State<ArchivedVersesSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.items.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (_pageController.hasClients) {
          int nextPage = _currentPage + 1;
          if (nextPage >= widget.items.length) {
            nextPage = 0;
          }
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ArchivedVersesSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart timer if the list changes
    if (oldWidget.items.length != widget.items.length) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.items.isEmpty) {
      // Return static banner image if no items are archived
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/sermon_banner.png',
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: HISpeakTheme.purpleMain.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            Image.asset(
              'assets/sermon_banner.png',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Opacity overlay to ensure readability
            Positioned.fill(
              child: Container(
                color: isDark 
                    ? Colors.black.withOpacity(0.4) 
                    : Colors.white.withOpacity(0.15),
              ),
            ),
            // PageView containing verses
            PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final displayTitle = item.title.replaceAll('VERSE OF THE DAY: ', '').toUpperCase();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: PremiumGlassCard(
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                displayTitle,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: HISpeakTheme.purpleMain,
                                  letterSpacing: 0.8,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.date,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.content,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Slide indicator dots
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: _currentPage == index ? 10 : 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? HISpeakTheme.purpleMain
                          : (isDark ? Colors.white30 : Colors.black12),
                      borderRadius: BorderRadius.circular(2),
                    ),
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

class _CrossIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _CrossIcon({
    Key? key,
    this.size = 54.0,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CrossPainter(color: color),
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  final Color color;

  _CrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width * 0.14;

    // Vertical beam of the cross
    final verticalRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (size.width - barWidth) / 2,
        size.height * 0.05,
        barWidth,
        size.height * 0.90,
      ),
      Radius.circular(barWidth / 2),
    );
    canvas.drawRRect(verticalRect, paint);

    // Horizontal beam of the cross
    final horizontalRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.15,
        size.height * 0.28,
        size.width * 0.70,
        barWidth,
      ),
      Radius.circular(barWidth / 2),
    );
    canvas.drawRRect(horizontalRect, paint);
  }

  @override
  bool shouldRepaint(covariant _CrossPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
