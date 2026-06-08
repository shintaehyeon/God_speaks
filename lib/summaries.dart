import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'state/sermon_provider.dart';
import 'models/sermon_summary.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menu clicked (Prototype)'),
                duration: Duration(milliseconds: 500),
              ),
            );
          },
        ),
        title: const Text(
          'Smart Summaries',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                // Focus profile setting page tab
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Swipe to settings tab to view profile'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEBF2FF),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Color(0xFF2F69F8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
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
                hintText: 'Search by date, topic, or scripture',
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),

          // 3. Summaries Timeline / Card List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.feed_outlined,
                          size: 48,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No summaries found',
                          style: TextStyle(
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
              ? const Color(0xFF2F69F8)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
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
              name,
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

  Widget _buildSermonCard(SermonSummary s, bool isExpanded) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sermonProvider = Provider.of<SermonProvider>(context);
    final isPremium = sermonProvider.userRole.contains("👑");
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          key: PageStorageKey(s.id),
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedId = expanded ? s.id : null;
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
                      color: Color(0xFF2F69F8),
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
                        color: Color(0xFF2F69F8),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Playing sermon audio... (Prototype)',
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.play_circle_fill_rounded,
                          size: 16,
                        ),
                        label: const Text('Listen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEBF2FF),
                          foregroundColor: const Color(0xFF2F69F8),
                          elevation: 0,
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
                      const SizedBox(width: 8),
                      // Premium AI QA button
                      ElevatedButton.icon(
                        onPressed: () {
                          if (isPremium) {
                            _showAIChatBottomSheet(context, s, sermonProvider);
                          } else {
                            _showPremiumUpgradeDialog(context);
                          }
                        },
                        icon: Icon(
                          isPremium
                              ? Icons.psychology_rounded
                              : Icons.lock_rounded,
                          size: 16,
                        ),
                        label: Text(isPremium ? 'AI 질문' : 'AI 질문 🔒'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPremium
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFFEF2F2),
                          foregroundColor: isPremium
                              ? const Color(0xFF2F69F8)
                              : const Color(0xFFEF4444),
                          elevation: 0,
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
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          if (isPremium) {
                            final shareText =
                                """
🌟 *Gods speak Sermon Summary Report* 🌟
📅 Date: ${s.date}
🏷️ Topic: ${s.category}
⛪ Title: ${s.title}
📖 Scripture: ${s.keyScripture}

💡 *Key Summary Notes:*
${s.bulletPoints.map((pt) => "• $pt").join("\n")}

🕊️ *Closing Takeaway:*
${s.takeaway}

Generated dynamically by Gods speak.
""";
                            // Copy to clipboard
                            Clipboard.setData(ClipboardData(text: shareText));
                            // Trigger native share sheet using share_plus.
                            SharePlus.instance.share(
                              ShareParams(
                                text: shareText,
                                subject: 'Gods speak Sermon Summary',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '📋 설교 요약본 리포트가 클립보드에 복사되고 공유 창이 열렸습니다!',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            _showPremiumUpgradeDialog(context);
                          }
                        },
                        icon: Icon(
                          isPremium ? Icons.share_rounded : Icons.lock_rounded,
                          size: 14,
                          color: isPremium
                              ? const Color(0xFF64748B)
                              : const Color(0xFFEF4444),
                        ),
                        label: Text(isPremium ? '공유' : '공유 🔒'),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
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
            children: const [
              Icon(Icons.stars_rounded, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text('Gods speak 프리미엄 👑'),
            ],
          ),
          content: const Text(
            '무제한 실시간 AI 설교 질의응답 피드백, 아름다운 마크다운 설교 리포트 내보내기/공유 기능을 원하십니까?\n\n로그아웃 하신 뒤, "구글 계정으로 간편 시작" 소셜 로그인을 완료하시면 평생 무료로 즉시 잠금 해제됩니다!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('나중에'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('설정(Settings) 탭으로 이동하여 로그아웃 후 다시 시도해 주세요!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F69F8),
                foregroundColor: Colors.white,
              ),
              child: const Text('업그레이드'),
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
      {
        "sender": "ai",
        "text":
            "안녕하세요! 'Gods speak'입니다. '${s.title}' 설교에 대해 궁금한 점을 은혜롭게 해결해 드리겠습니다. 편하게 무엇이든 질문해 주세요! 🕊️",
      },
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
                              const Text(
                                '설교 AI 어시스턴트',
                                style: TextStyle(
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
                            hintText: '설교 내용에 관해 궁금한 점을 적어보세요...',
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
