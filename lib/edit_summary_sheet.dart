import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/hispeak_localizations.dart';
import 'state/sermon_provider.dart';
import 'theme.dart';

class EditSummarySheet extends StatefulWidget {
  final String summaryId;
  final List<String> initialBulletPoints;
  final List<String> initialApplicationPoints;
  final List<String> initialPrayerPoints;
  final String initialUserComment;

  const EditSummarySheet({
    Key? key,
    required this.summaryId,
    required this.initialBulletPoints,
    required this.initialApplicationPoints,
    required this.initialPrayerPoints,
    required this.initialUserComment,
  }) : super(key: key);

  @override
  State<EditSummarySheet> createState() => _EditSummarySheetState();
}

class _EditSummarySheetState extends State<EditSummarySheet> {
  late TextEditingController _bulletController;
  late TextEditingController _appController;
  late TextEditingController _prayerController;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _bulletController = TextEditingController(
      text: widget.initialBulletPoints.join('\n'),
    );
    _appController = TextEditingController(
      text: widget.initialApplicationPoints.join('\n'),
    );
    _prayerController = TextEditingController(
      text: widget.initialPrayerPoints.join('\n'),
    );
    _commentController = TextEditingController(text: widget.initialUserComment);
  }

  @override
  void dispose() {
    _bulletController.dispose();
    _appController.dispose();
    _prayerController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) async {
    final provider = Provider.of<SermonProvider>(context, listen: false);

    // Split text by lines, trim whitespace, and filter out empty lines
    List<String> bulletPoints = _bulletController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    List<String> appPoints = _appController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    List<String> prayerPoints = _prayerController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    String userComment = _commentController.text.trim();

    await provider.updateSummary(
      id: widget.summaryId,
      bulletPoints: bulletPoints,
      applicationPoints: appPoints,
      prayerPoints: prayerPoints,
      userComment: userComment,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                context.l10n.t('summaryEditSaved'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: HISpeakTheme.purpleMain,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom Sheet handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    color: HISpeakTheme.purpleMain,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.t('editSummaryTitle'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.t('editSummaryDesc'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),

              // 1. 핵심 요약
              _buildSectionTitle(
                context,
                '💡 ${context.l10n.t('summaryCore')} (${context.l10n.t('onePerLine')})',
                isDark,
              ),
              _buildTextField(
                controller: _bulletController,
                hintText: context.l10n.t('summaryHint'),
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // 2. 삶의 적용점
              _buildSectionTitle(
                context,
                '🏃 ${context.l10n.t('lifeApplication')} (${context.l10n.t('onePerLine')})',
                isDark,
              ),
              _buildTextField(
                controller: _appController,
                hintText: context.l10n.t('applicationHint'),
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // 3. 기도 제목
              _buildSectionTitle(
                context,
                '🙏 ${context.l10n.t('prayerPoints')} (${context.l10n.t('onePerLine')})',
                isDark,
              ),
              _buildTextField(
                controller: _prayerController,
                hintText: context.l10n.t('prayerHint'),
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // 4. 나의 메모 / 코멘트
              _buildSectionTitle(
                context,
                '✍️ ${context.l10n.t('myMemo')} (${context.l10n.t('freeInput')})',
                isDark,
              ),
              _buildTextField(
                controller: _commentController,
                hintText: context.l10n.t('memoHint'),
                isDark: isDark,
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      child: Text(
                        context.l10n.t('cancel'),
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFFA78BFA),
                                ]
                              : [
                                  const Color(0xFF7C3AED),
                                  const Color(0xFF9061F9),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _save(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          context.l10n.t('save'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    int maxLines = 3,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontFamily: 'Inter',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: HISpeakTheme.purpleMain,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
