import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'state/sermon_provider.dart';
import 'models/sermon_summary.dart';
import 'theme.dart';
import 'edit_summary_sheet.dart';
import 'l10n/hispeak_localizations.dart';

class SummariesPage extends StatefulWidget {
  const SummariesPage({Key? key}) : super(key: key);

  @override
  State<SummariesPage> createState() => _SummariesPageState();
}

class _SummariesPageState extends State<SummariesPage> {
  String _selectedFilter = "All Archive";
  String _searchQuery = "";
  String? _expandedId; // ID of the currently expanded sermon card

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);

    // Filter summaries based on category and search query
    List<SermonSummary> filteredList = sermonProvider.summaries.where((s) {
      bool matchesFilter =
          _selectedFilter == "All Archive" ||
          s.category.toUpperCase() == _selectedFilter.toUpperCase();

      bool matchesSearch =
          s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.keyScripture.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.bulletPoints.any(
            (pt) => pt.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      return matchesFilter && matchesSearch;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          context.l10n.t('smartSummaries'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/archive');
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF3F0FF),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.bookmark_rounded,
                  size: 18,
                  color: HISpeakTheme.purpleMain,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          HISpeakTheme.buildIridescentBg(context),
          Column(
            children: [
              // 1. Search Bar
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: context.l10n.t('searchSummaryHint'),
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8F9FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // 2. Horizontal Filter Categories
              Container(
                color: Theme.of(context).colorScheme.surface,
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    _buildFilterChip("All Archive"),
                    _buildFilterChip("Theology", hasArrow: true),
                    _buildFilterChip("Recent", hasCalendar: true),
                    _buildFilterChip("Faith"),
                    _buildFilterChip("Wisdom"),
                    _buildFilterChip("Purpose"),
                  ],
                ),
              ),

              Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
              ),

              // 3. Summaries Timeline / Card List
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.feed_outlined,
                              size: 48,
                              color: Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.t('noSummaries'),
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final s = filteredList[index];
                          final isExpanded = _expandedId == s.id;

                          // Expand the first card by default initially
                          if (_expandedId == null && index == 0) {
                            _expandedId = s.id;
                          }

                          return _buildSermonCard(s, isExpanded);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String name, {
    bool hasArrow = false,
    bool hasCalendar = false,
  }) {
    final isSelected = _selectedFilter == name;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? HISpeakTheme.purpleMain
              : (isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white.withOpacity(0.35)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? HISpeakTheme.purpleMain
                : (isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.white.withOpacity(0.5)),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCalendar) ...[
              Icon(
                Icons.calendar_today_rounded,
                size: 11,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              _localizedFilterName(name),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
              ),
            ),
            if (hasArrow) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _localizedFilterName(String name) {
    switch (name) {
      case 'All Archive':
        return context.l10n.t('allArchive');
      case 'Theology':
        return context.l10n.t('theology');
      case 'Recent':
        return context.l10n.t('recent');
      case 'Faith':
        return context.l10n.t('faith');
      case 'Wisdom':
        return context.l10n.t('wisdom');
      case 'Purpose':
        return context.l10n.t('purpose');
      default:
        return name;
    }
  }

  Widget _buildSermonCard(SermonSummary s, bool isExpanded) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sermonProvider = Provider.of<SermonProvider>(context);
    final isPremium = true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(s.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24.0),
          decoration: BoxDecoration(
            color: Colors.redAccent.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                context.l10n.t('delete'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  title: Text(
                    context.l10n.t('deleteSummary'),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    context.l10n.t('deleteSummaryConfirm'),
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                      fontSize: 14,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        context.l10n.t('cancel'),
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(context.l10n.t('delete')),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (direction) async {
          await sermonProvider.deleteSummary(s.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.t('summaryDeleted')),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: PremiumGlassCard(
          borderRadius: 16,
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: isExpanded,
              key: PageStorageKey(s.id),
              onExpansionChanged: (expanded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _expandedId = expanded ? s.id : null;
                    });
                  }
                });
              },
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        s.date,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: HISpeakTheme.purpleMain,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3.5,
                        height: 3.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCBD5E1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              trailing: AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9),
                        height: 20,
                      ),

                      if (s.applicationPoints.isEmpty &&
                          s.prayerPoints.isEmpty) ...[
                        MarkdownBody(
                          data: _summaryMarkdown(s.bulletPoints),
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                              fontSize: 13,
                              height: 1.4,
                            ),
                            strong: TextStyle(
                              color: isDark
                                  ? const Color(0xFFF1F5F9)
                                  : const Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                            ),
                            listBullet: const TextStyle(
                              color: HISpeakTheme.purpleMain,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else ...[
                        // Key Scripture & Parallel Verse Container
                        if (s.keyScripture.isNotEmpty &&
                            s.keyScripture != '실시간 음성 인식 세션') ...[
                          Text(
                            context.l10n.t('relatedScripture'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F172A).withOpacity(0.4)
                                  : const Color(0xFFF8FAFC).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.keyScripture,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFC4B5FD)
                                        : HISpeakTheme.purpleMain,
                                  ),
                                ),
                                if (s.keyScriptureTextKor.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    s.keyScriptureTextKor,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF334155),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                                if (s.keyScriptureTextEng.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    s.keyScriptureTextEng,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
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
                        if (s.bulletPoints.isNotEmpty) ...[
                          Text(
                            context.l10n.t('summaryCore'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...s.bulletPoints.map(
                            (pt) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      color: HISpeakTheme.purpleMain,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      pt,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF334155),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Application Points
                        if (s.applicationPoints.isNotEmpty) ...[
                          Text(
                            context.l10n.t('lifeApplication'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...s.applicationPoints.map(
                            (pt) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 14,
                                    color: Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      pt,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF334155),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Prayer Points
                        if (s.prayerPoints.isNotEmpty) ...[
                          Text(
                            context.l10n.t('prayerPoints'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...s.prayerPoints.map(
                            (pt) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.favorite_rounded,
                                    size: 14,
                                    color: Color(0xFFEC4899),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      pt,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF334155),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(height: 8),

                      if (s.userComment.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E38)
                                : const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF3B2E5C)
                                  : const Color(0xFFE5DEFF),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.edit_note_rounded,
                                    color: HISpeakTheme.purpleMain,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '✍️ ${context.l10n.t('myMeditationMemo')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xFFC4B5FD)
                                          : const Color(0xFF6D28D9),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.userComment,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFFE2E8F0)
                                      : const Color(0xFF475569),
                                  height: 1.45,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Bottom Action Buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              if (isPremium) {
                                final shareText =
                                    """
🌟 *HISpeak Sermon Summary Report* 🌟
📅 Date: ${s.date}
🏷️ Topic: ${s.category}
⛪ Title: ${s.title}
📖 Scripture: ${s.keyScripture}

💡 *Key Summary Notes:*
${s.bulletPoints.map((pt) => "• $pt").join("\n")}

🕊️ *Closing Takeaway:*
${s.takeaway}

Generated dynamically by HISpeak.
""";
                                // Copy to clipboard
                                Clipboard.setData(
                                  ClipboardData(text: shareText),
                                );
                                // Trigger native share sheet using share_plus.
                                SharePlus.instance.share(
                                  ShareParams(
                                    text: shareText,
                                    subject: 'HISpeak Sermon Summary',
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '📋 ${context.l10n.t('shareReportCopied')}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                _showPremiumUpgradeDialog(context);
                              }
                            },
                            icon: Icon(
                              isPremium
                                  ? Icons.share_rounded
                                  : Icons.lock_rounded,
                              size: 14,
                              color: isPremium
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFFEF4444),
                            ),
                            label: Text(
                              isPremium
                                  ? context.l10n.t('share')
                                  : '${context.l10n.t('shareLocked')} 🔒',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isPremium
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFFEF4444),
                              side: BorderSide(
                                color: isPremium
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFFFCA5A5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          // Edit Summary Button
                          OutlinedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => EditSummarySheet(
                                  summaryId: s.id,
                                  initialBulletPoints: s.bulletPoints,
                                  initialApplicationPoints: s.applicationPoints,
                                  initialPrayerPoints: s.prayerPoints,
                                  initialUserComment: s.userComment,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.edit_note_rounded,
                              size: 16,
                              color: HISpeakTheme.purpleMain,
                            ),
                            label: Text(context.l10n.t('edit')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: HISpeakTheme.purpleMain,
                              side: const BorderSide(
                                color: HISpeakTheme.lightPurple,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _summaryMarkdown(List<String> points) {
    return points
        .map((point) {
          final trimmed = point.trim();
          final escaped = trimmed.replaceAll('\n', '\n  ');
          return '- $escaped';
        })
        .join('\n\n');
  }

  void _showPremiumUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text('${context.l10n.t('premiumTitle')} 👑'),
            ],
          ),
          content: Text(context.l10n.t('premiumDesc')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.t('later')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.t('loginPromptSnack'))),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F69F8),
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.t('upgrade')),
            ),
          ],
        );
      },
    );
  }

  void _showAIChatBottomSheet(
    BuildContext context,
    SermonSummary s,
    SermonProvider provider,
  ) {
    final TextEditingController questionController = TextEditingController();
    final List<Map<String, String>> chatMessages = [
      {"sender": "ai", "text": context.l10n.t('aiGreeting')},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEBF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.psychology_rounded,
                              color: Color(0xFF2F69F8),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.t('aiAssistant'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  s.title,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),

                  // Chat Area
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        final msg = chatMessages[index];
                        final isAI = msg['sender'] == 'ai';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: isAI
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isAI) ...[
                                const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Color(0xFFEBF2FF),
                                  child: Icon(
                                    Icons.psychology_rounded,
                                    size: 14,
                                    color: Color(0xFF2F69F8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAI
                                        ? (isDark
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFFF1F5F9))
                                        : const Color(0xFF2F69F8),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: isAI
                                          ? Radius.zero
                                          : const Radius.circular(16),
                                      bottomRight: isAI
                                          ? const Radius.circular(16)
                                          : Radius.zero,
                                    ),
                                  ),
                                  child: Text(
                                    msg['text']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isAI
                                          ? (isDark
                                                ? const Color(0xFFF1F5F9)
                                                : const Color(0xFF334155))
                                          : Colors.white,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                              if (!isAI) ...[
                                const SizedBox(width: 8),
                                const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Color(0xFFE2E8F0),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Input row
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: questionController,
                          decoration: InputDecoration(
                            hintText: context.l10n.t('aiQuestionHint'),
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      provider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF2F69F8),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () async {
                                  final q = questionController.text.trim();
                                  if (q.isEmpty) return;

                                  setModalState(() {
                                    chatMessages.add({
                                      "sender": "user",
                                      "text": q,
                                    });
                                    questionController.clear();
                                  });

                                  // Call provider AI
                                  final String summaryText = s.bulletPoints
                                      .join("\n");
                                  final String reply = await provider
                                      .askGeminiAboutSermon(
                                        s.title,
                                        summaryText,
                                        q,
                                      );

                                  setModalState(() {
                                    chatMessages.add({
                                      "sender": "ai",
                                      "text": reply,
                                    });
                                  });
                                },
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
