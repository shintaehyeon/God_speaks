import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'state/sermon_provider.dart';
import 'models/saved_item.dart';
import 'theme.dart';
import 'l10n/hispeak_localizations.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({Key? key}) : super(key: key);

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter items based on type and search query
    final verses = sermonProvider.archiveItems.where((item) {
      if (item.type != 'verse') return false;
      if (_searchText.isEmpty) return true;
      return item.title.toLowerCase().contains(_searchText.toLowerCase()) ||
          item.content.toLowerCase().contains(_searchText.toLowerCase()) ||
          item.authorOrVersion.toLowerCase().contains(
            _searchText.toLowerCase(),
          );
    }).toList();

    final quotes = sermonProvider.archiveItems.where((item) {
      if (item.type != 'quote') return false;
      if (_searchText.isEmpty) return true;
      return item.title.toLowerCase().contains(_searchText.toLowerCase()) ||
          item.content.toLowerCase().contains(_searchText.toLowerCase()) ||
          item.authorOrVersion.toLowerCase().contains(
            _searchText.toLowerCase(),
          );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          HISpeakTheme.buildIridescentBg(context),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.t('searchArchiveHint'),
                        hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchText = val;
                        });
                      },
                    )
                  : Text(
                      context.l10n.t('archiveTitle'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close_rounded : Icons.search_rounded,
                    size: 22,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isSearching) {
                        _isSearching = false;
                        _searchText = '';
                        _searchController.clear();
                      } else {
                        _isSearching = true;
                      }
                    });
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: HISpeakTheme.purpleMain,
                indicatorWeight: 3,
                labelColor: HISpeakTheme.purpleMain,
                unselectedLabelColor: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                tabs: [
                  Tab(text: context.l10n.t('bibleVerses')),
                  Tab(text: context.l10n.t('keyQuotes')),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildItemTab(verses, sermonProvider),
                _buildItemTab(quotes, sermonProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTab(List<SavedItem> items, SermonProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 48,
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('noArchive'),
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSaved = provider.savedItemIds.contains(item.id);

        // Custom UI designs matching the screenshots
        if (item.type == 'verse') {
          final coverImages = [
            'assets/bible_verse.png',
            'assets/bible_verse_2.png',
            'assets/bible_verse_3.png',
            'assets/bible_verse_4.png',
          ];
          final coverAsset = coverImages[index % coverImages.length];

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withOpacity(0.85)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : const Color(0xFFF1F5F9),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cover Image Container for all bible verses
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.asset(
                        coverAsset,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Dark shade overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.18),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    // Verse Header Badge (e.g. VERSE OF THE DAY or SERVICE TYPE)
                    Positioned(
                      left: 16,
                      top: 55,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: HISpeakTheme.purpleMain,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.serviceType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    // Scripture Title overlay
                    Positioned(
                      left: 16,
                      top: 82,
                      child: Text(
                        item.title.replaceAll('VERSE OF THE DAY: ', ''),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sunday service label underneath cover
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.serviceType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            item.date,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Verse Text Content
                      Text(
                        item.content,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Footer action panel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.authorOrVersion,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.share_rounded,
                                  size: 18,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                                onPressed: () {
                                  final text =
                                      "${item.content}\n\n— ${item.authorOrVersion}";
                                  Clipboard.setData(ClipboardData(text: text));
                                  SharePlus.instance.share(
                                    ShareParams(
                                      text: text,
                                      subject: 'Sermon Verse',
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.t('copiedVerse'),
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              _buildSaveButton(
                                isSaved,
                                () => provider.toggleSaveItem(item.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Quote Card Design (With double quote decoration)
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withOpacity(0.85)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : const Color(0xFFF1F5F9),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1B4B)
                                : const Color(0xFFEBF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.format_quote_rounded,
                            size: 14,
                            color: HISpeakTheme.purpleMain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.date,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quote text
                Text(
                  item.content,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '— ' + item.authorOrVersion,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.share_rounded,
                            size: 18,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          onPressed: () {
                            final text =
                                "${item.content}\n\n— ${item.authorOrVersion}";
                            Clipboard.setData(ClipboardData(text: text));
                            SharePlus.instance.share(
                              ShareParams(
                                text: text,
                                subject: 'Sermon Key Quote',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.t('copiedQuote')),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        _buildSaveButton(
                          isSaved,
                          () => provider.toggleSaveItem(item.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSaveButton(bool isSaved, VoidCallback onPressed) {
    if (isSaved) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.bookmark_rounded, size: 14),
        label: Text(context.l10n.t('saved')),
        style: ElevatedButton.styleFrom(
          backgroundColor: HISpeakTheme.purpleMain,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.bookmark_border_rounded, size: 14),
        label: Text(context.l10n.t('save')),
        style: OutlinedButton.styleFrom(
          foregroundColor: HISpeakTheme.purpleMain,
          side: BorderSide(color: HISpeakTheme.purpleMain, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }
  }
}
