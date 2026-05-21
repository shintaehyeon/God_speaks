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
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        actions: [
          // Language selector chip
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: const [
                Text(
                  '한국어 ➔ 🇺🇸 English',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F69F8),
                  ),
                ),
              ],
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
              const Spacer(flex: 2),

              // Giant Blue Recording Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    sermonProvider.toggleRecording();
                    Navigator.pushNamed(context, '/live');
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
}
