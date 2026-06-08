import 'dart:math';

import 'package:flutter/material.dart';

import 'models/bible.dart';
import 'services/bible_repository.dart';

class BiblePage extends StatefulWidget {
  const BiblePage({super.key});

  @override
  State<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  final BibleRepository _repository = BibleRepository();
  final TextEditingController _searchController = TextEditingController();

  late final Future<BibleLibrary> _libraryFuture;

  BibleViewMode _viewMode = BibleViewMode.parallel;
  int _bookIndex = 0;
  int _chapterIndex = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _libraryFuture = _repository.loadLibrary();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('성경'),
        actions: [
          FutureBuilder<BibleLibrary>(
            future: _libraryFuture,
            builder: (context, snapshot) {
              return IconButton(
                tooltip: '출처',
                onPressed: snapshot.hasData
                    ? () => _showSourceSheet(context, snapshot.data!)
                    : null,
                icon: const Icon(Icons.info_outline_rounded),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<BibleLibrary>(
        future: _libraryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _ErrorState(
              message: snapshot.error?.toString() ?? '성경 데이터를 불러오지 못했습니다.',
            );
          }

          return _buildReader(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildReader(BuildContext context, BibleLibrary library) {
    final chapterCount = _chapterCount(library, _bookIndex);
    final safeChapterIndex = min(_chapterIndex, max(0, chapterCount - 1));
    final isSearching = _query.trim().isNotEmpty;

    return SafeArea(
      child: Column(
        children: [
          _BibleControls(
            library: library,
            viewMode: _viewMode,
            bookIndex: _bookIndex,
            chapterIndex: safeChapterIndex,
            searchController: _searchController,
            query: _query,
            onViewModeChanged: (mode) {
              setState(() {
                _viewMode = mode;
              });
            },
            onBookChanged: (index) {
              setState(() {
                _bookIndex = index;
                _chapterIndex = 0;
                _query = '';
                _searchController.clear();
              });
            },
            onChapterChanged: (index) {
              setState(() {
                _chapterIndex = index;
                _query = '';
                _searchController.clear();
              });
            },
            onQueryChanged: (query) {
              setState(() {
                _query = query;
              });
            },
            onClearQuery: () {
              setState(() {
                _query = '';
                _searchController.clear();
              });
            },
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSearching
                  ? _SearchResultsList(
                      key: ValueKey('search-${_viewMode.name}-$_query'),
                      library: library,
                      viewMode: _viewMode,
                      query: _query,
                      onResultSelected: _moveToResult,
                    )
                  : _ChapterVerseList(
                      key: ValueKey(
                        'chapter-${_viewMode.name}-$_bookIndex-$safeChapterIndex',
                      ),
                      library: library,
                      viewMode: _viewMode,
                      bookIndex: _bookIndex,
                      chapterIndex: safeChapterIndex,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  int _chapterCount(BibleLibrary library, int bookIndex) {
    final koreanCount = library.korean.books[bookIndex].chapters.length;
    final englishCount = library.english.books[bookIndex].chapters.length;
    return min(koreanCount, englishCount);
  }

  void _moveToResult(BibleSearchResult result) {
    setState(() {
      _bookIndex = result.bookIndex;
      _chapterIndex = result.chapterIndex;
      _query = '';
      _searchController.clear();
    });
  }

  void _showSourceSheet(BuildContext context, BibleLibrary library) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '성경 데이터',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _SourceBlock(
                  title: '한국어',
                  translation:
                      '${library.korean.translation} (${library.korean.abbreviation})',
                  license: library.korean.license,
                  source: library.korean.source,
                ),
                const SizedBox(height: 12),
                _SourceBlock(
                  title: 'English',
                  translation:
                      '${library.english.translation} (${library.english.abbreviation})',
                  license: library.english.license,
                  source: library.english.source,
                ),
                const SizedBox(height: 12),
                const Text(
                  '한국어 본문은 Korean Revised Version 1952/1961 계열이며 개역개정이 아닙니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BibleControls extends StatelessWidget {
  const _BibleControls({
    required this.library,
    required this.viewMode,
    required this.bookIndex,
    required this.chapterIndex,
    required this.searchController,
    required this.query,
    required this.onViewModeChanged,
    required this.onBookChanged,
    required this.onChapterChanged,
    required this.onQueryChanged,
    required this.onClearQuery,
  });

  final BibleLibrary library;
  final BibleViewMode viewMode;
  final int bookIndex;
  final int chapterIndex;
  final TextEditingController searchController;
  final String query;
  final ValueChanged<BibleViewMode> onViewModeChanged;
  final ValueChanged<int> onBookChanged;
  final ValueChanged<int> onChapterChanged;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chapterCount = min(
      library.korean.books[bookIndex].chapters.length,
      library.english.books[bookIndex].chapters.length,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<BibleViewMode>(
            selected: {viewMode},
            onSelectionChanged: (selected) {
              onViewModeChanged(selected.first);
            },
            segments: const [
              ButtonSegment<BibleViewMode>(
                value: BibleViewMode.korean,
                icon: Icon(Icons.translate_rounded, size: 18),
                label: Text('한국어'),
              ),
              ButtonSegment<BibleViewMode>(
                value: BibleViewMode.english,
                icon: Icon(Icons.language_rounded, size: 18),
                label: Text('English'),
              ),
              ButtonSegment<BibleViewMode>(
                value: BibleViewMode.parallel,
                icon: Icon(Icons.view_agenda_outlined, size: 18),
                label: Text('한영'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey('book-$bookIndex-${viewMode.name}'),
                  initialValue: bookIndex,
                  isExpanded: true,
                  decoration: _fieldDecoration(
                    context,
                    label: '권',
                    icon: Icons.menu_book_rounded,
                  ),
                  items: List.generate(
                    library.bookCount,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        library.bookLabel(index, viewMode),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      onBookChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 112,
                child: DropdownButtonFormField<int>(
                  key: ValueKey('chapter-$bookIndex-$chapterIndex'),
                  initialValue: chapterIndex,
                  isExpanded: true,
                  decoration: _fieldDecoration(
                    context,
                    label: '장',
                    icon: Icons.format_list_numbered_rounded,
                  ),
                  items: List.generate(
                    chapterCount,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text('${index + 1}장'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      onChapterChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration:
                _fieldDecoration(
                  context,
                  label: '구절 검색',
                  icon: Icons.search_rounded,
                ).copyWith(
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: '검색 지우기',
                          onPressed: onClearQuery,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2F69F8), width: 1.4),
      ),
    );
  }
}

class _ChapterVerseList extends StatelessWidget {
  const _ChapterVerseList({
    super.key,
    required this.library,
    required this.viewMode,
    required this.bookIndex,
    required this.chapterIndex,
  });

  final BibleLibrary library;
  final BibleViewMode viewMode;
  final int bookIndex;
  final int chapterIndex;

  @override
  Widget build(BuildContext context) {
    final koreanBook = library.korean.books[bookIndex];
    final englishBook = library.english.books[bookIndex];
    final koreanChapter = koreanBook.chapters[chapterIndex];
    final englishChapter = englishBook.chapters[chapterIndex];
    final verseCount = min(
      koreanChapter.verses.length,
      englishChapter.verses.length,
    );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: verseCount + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ChapterHeader(
            title: _chapterTitle(
              koreanBook.name,
              englishBook.name,
              koreanChapter.number,
              viewMode,
            ),
            subtitle: viewMode.label,
          );
        }

        final verseIndex = index - 1;
        return _VerseTile(
          verseNumber: koreanChapter.verses[verseIndex].verse,
          koreanText: koreanChapter.verses[verseIndex].text,
          englishText: englishChapter.verses[verseIndex].text,
          viewMode: viewMode,
        );
      },
    );
  }

  String _chapterTitle(
    String koreanBook,
    String englishBook,
    int chapter,
    BibleViewMode mode,
  ) {
    switch (mode) {
      case BibleViewMode.korean:
        return '$koreanBook $chapter장';
      case BibleViewMode.english:
        return '$englishBook $chapter';
      case BibleViewMode.parallel:
        return '$koreanBook / $englishBook $chapter장';
    }
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    super.key,
    required this.library,
    required this.viewMode,
    required this.query,
    required this.onResultSelected,
  });

  final BibleLibrary library;
  final BibleViewMode viewMode;
  final String query;
  final ValueChanged<BibleSearchResult> onResultSelected;

  @override
  Widget build(BuildContext context) {
    final results = library.search(query, viewMode);

    if (results.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_off_rounded,
        title: '검색 결과 없음',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: results.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ChapterHeader(title: '검색 결과', subtitle: '${results.length}개');
        }

        final result = results[index - 1];
        return _SearchResultTile(
          result: result,
          viewMode: viewMode,
          onTap: () => onResultSelected(result),
        );
      },
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F69F8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseTile extends StatelessWidget {
  const _VerseTile({
    required this.verseNumber,
    required this.koreanText,
    required this.englishText,
    required this.viewMode,
  });

  final int verseNumber;
  final String koreanText;
  final String englishText;
  final BibleViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    return _VerseSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VerseNumber(number: verseNumber),
          const SizedBox(width: 12),
          Expanded(
            child: _VerseTextGroup(
              koreanText: koreanText,
              englishText: englishText,
              viewMode: viewMode,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.viewMode,
    required this.onTap,
  });

  final BibleSearchResult result;
  final BibleViewMode viewMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reference = viewMode == BibleViewMode.english
        ? '${result.englishBookName} ${result.chapter}:${result.verse}'
        : '${result.koreanBookName} ${result.chapter}:${result.verse}';

    return _VerseSurface(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VerseNumber(number: result.verse),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reference,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F69F8),
                  ),
                ),
                const SizedBox(height: 8),
                _VerseTextGroup(
                  koreanText: result.koreanText,
                  englishText: result.englishText,
                  viewMode: viewMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseSurface extends StatelessWidget {
  const _VerseSurface({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: child,
    );

    if (onTap == null) {
      return surface;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: surface,
      ),
    );
  }
}

class _VerseNumber extends StatelessWidget {
  const _VerseNumber({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2F69F8),
        ),
      ),
    );
  }
}

class _VerseTextGroup extends StatelessWidget {
  const _VerseTextGroup({
    required this.koreanText,
    required this.englishText,
    required this.viewMode,
  });

  final String koreanText;
  final String englishText;
  final BibleViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1E293B);
    final secondaryColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);

    switch (viewMode) {
      case BibleViewMode.korean:
        return Text(
          koreanText,
          style: TextStyle(
            fontSize: 16,
            height: 1.55,
            color: primaryColor,
            fontWeight: FontWeight.w500,
          ),
        );
      case BibleViewMode.english:
        return Text(
          englishText,
          style: TextStyle(
            fontSize: 16,
            height: 1.55,
            color: primaryColor,
            fontWeight: FontWeight.w500,
          ),
        );
      case BibleViewMode.parallel:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              koreanText,
              style: TextStyle(
                fontSize: 16,
                height: 1.55,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              englishText,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: secondaryColor,
              ),
            ),
          ],
        );
    }
  }
}

class _SourceBlock extends StatelessWidget {
  const _SourceBlock({
    required this.title,
    required this.translation,
    required this.license,
    required this.source,
  });

  final String title;
  final String translation;
  final String license;
  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F69F8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            translation,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '$license · $source',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
