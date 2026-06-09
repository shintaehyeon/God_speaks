import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/bible.dart';

class BibleRepository {
  static Future<BibleLibrary>? _cachedLibrary;

  Future<BibleLibrary> loadLibrary() {
    return _cachedLibrary ??= _loadLibrary();
  }

  Future<BibleLibrary> _loadLibrary() async {
    final payloads = await Future.wait([
      rootBundle.loadString('assets/bibles/korean.json'),
      rootBundle.loadString('assets/bibles/web.json'),
    ]);

    return BibleLibrary(
      korean: BibleTranslation.fromJson(
        jsonDecode(payloads[0]) as Map<String, dynamic>,
      ),
      english: BibleTranslation.fromJson(
        jsonDecode(payloads[1]) as Map<String, dynamic>,
      ),
    );
  }
}

class BibleLibrary {
  BibleLibrary({required this.korean, required this.english}) {
    buildBookMap();
  }

  final BibleTranslation korean;
  final BibleTranslation english;
  final Map<String, int> bookNameToIndex = {};

  int get bookCount => min(korean.books.length, english.books.length);

  void buildBookMap() {
    for (int i = 0; i < korean.books.length; i++) {
      final korName = korean.books[i].name.replaceAll(' ', '').toLowerCase();
      bookNameToIndex[korName] = i;
    }
    for (int i = 0; i < english.books.length; i++) {
      final engName = english.books[i].name.replaceAll(' ', '').toLowerCase();
      bookNameToIndex[engName] = i;
    }

    // Standard Korean Abbreviations (66 books)
    final korAbbrs = [
      '창', '출', '레', '민', '신', '수', '삿', '룻', '삼상', '삼하', '왕상', '왕하', '대상', '대하', '스', '느', '에', '욥',
      '시', '잠', '전', '아', '사', '렘', '애', '겔', '단', '호', '욜', '암', '옵', '욘', '미', '나', '합', '습', '학', '스', '말',
      '마', '막', '눅', '요', '행', '롬', '고전', '고후', '갈', '엡', '빌', '골', '살전', '살후', '딤전', '딤후', '딛', '몬', '히', '야',
      '벧전', '벧후', '요일', '요이', '요삼', '유', '계'
    ];
    for (int i = 0; i < korAbbrs.length; i++) {
      if (i < bookCount) {
        bookNameToIndex[korAbbrs[i].toLowerCase()] = i;
      }
    }

    // Standard English Abbreviations (66 books)
    final engAbbrs = {
      'gen': 0, 'ex': 1, 'exod': 1, 'lev': 2, 'num': 3, 'deut': 4, 'josh': 5, 'judg': 6, 'ruth': 7,
      '1sam': 8, '2sam': 9, '1ki': 10, '2ki': 11, '1kings': 10, '2kings': 11, '1chr': 12, '2chr': 13,
      '1chron': 12, '2chron': 13, 'ezra': 14, 'neh': 15, 'esth': 16, 'job': 17, 'ps': 18, 'psalm': 18,
      'psalms': 18, 'prov': 19, 'ecc': 20, 'eccl': 20, 'eccles': 20, 'song': 21, 'isa': 22, 'jer': 23,
      'lam': 24, 'eze': 25, 'ezek': 25, 'dan': 26, 'hos': 27, 'joel': 28, 'amos': 29, 'ob': 30, 'obad': 30,
      'jon': 31, 'jonah': 31, 'mic': 32, 'nah': 33, 'hab': 34, 'zep': 35, 'zeph': 35, 'hag': 36, 'zec': 37,
      'zech': 37, 'mal': 38, 'mat': 39, 'matt': 39, 'mk': 40, 'mrk': 40, 'mark': 40, 'lk': 41, 'luk': 41,
      'luke': 41, 'jn': 42, 'joh': 42, 'john': 42, 'act': 43, 'acts': 43, 'rom': 44, '1co': 45, '2co': 46,
      '1cor': 45, '2cor': 46, 'gal': 47, 'eph': 48, 'phil': 49, 'col': 50, '1th': 51, '2th': 52, '1thess': 51,
      '2thess': 52, '1ti': 53, '2ti': 54, '1tim': 53, '2tim': 54, 'tit': 55, 'titus': 55, 'phm': 56, 'phile': 56,
      'philem': 56, 'heb': 57, 'jas': 58, '1pe': 59, '2pe': 60, '1pet': 59, '2pet': 60, '1jn': 61, '2jn': 62,
      '3jn': 63, '1john': 61, '2john': 62, '3john': 63, 'jud': 64, 'jude': 64, 'rev': 65
    };
    engAbbrs.forEach((abbr, idx) {
      if (idx < bookCount) {
        bookNameToIndex[abbr.toLowerCase()] = idx;
      }
    });
  }

  int findBookIndex(String bookNameOrAbbr) {
    final cleaned = bookNameOrAbbr.replaceAll(' ', '').toLowerCase();
    return bookNameToIndex[cleaned] ?? -1;
  }

  BibleSearchResult? lookupReference(String bookNameOrAbbr, int chapter, [int? verse]) {
    final bookIndex = findBookIndex(bookNameOrAbbr);
    if (bookIndex == -1) return null;

    final korBook = korean.books[bookIndex];
    final engBook = english.books[bookIndex];

    if (chapter < 1 || chapter > korBook.chapters.length) return null;
    final korChapter = korBook.chapters[chapter - 1];
    final engChapter = engBook.chapters[chapter - 1];

    final verseNum = verse ?? 1;
    if (verseNum < 1 || verseNum > korChapter.verses.length) return null;
    final korVerse = korChapter.verses[verseNum - 1];
    final engVerse = engChapter.verses[verseNum - 1];

    return BibleSearchResult(
      bookIndex: bookIndex,
      chapterIndex: chapter - 1,
      verseIndex: verseNum - 1,
      koreanBookName: korBook.name,
      englishBookName: engBook.name,
      chapter: chapter,
      verse: verseNum,
      koreanText: korVerse.text,
      englishText: engVerse.text,
    );
  }

  List<BibleSearchResult> parseReferences(String text) {
    final results = <BibleSearchResult>[];
    if (text.isEmpty) return results;

    // Pattern 1: Book name + chapter + : or 장 + verse + (optional) 절
    final pattern1 = RegExp(
      r'([1-3]?\s*[a-zA-Z가-힣]+)\s*(?:장|:)?\s*(\d+)\s*(?:장|:)\s*(\d+)(?:\s*절)?',
      caseSensitive: false,
    );

    // Pattern 2: Book name + chapter + 장 (no verse)
    final pattern2 = RegExp(
      r'([1-3]?\s*[a-zA-Z가-힣]+)\s*(\d+)\s*장',
      caseSensitive: false,
    );

    // Pattern 3: Book name + space + chapter (simple fallback)
    final pattern3 = RegExp(
      r'([1-3]?\s*[a-zA-Z가-힣]+)\s*(\d+)',
      caseSensitive: false,
    );

    final seen = <String>{};
    final matchedIndices = <_Range>[];

    bool overlaps(int start, int end) {
      for (final range in matchedIndices) {
        if (start < range.end && end > range.start) {
          return true;
        }
      }
      return false;
    }

    void addResult(BibleSearchResult? res, int start, int end) {
      if (res != null) {
        final key = '${res.bookIndex}-${res.chapter}-${res.verse}';
        if (!seen.contains(key)) {
          seen.add(key);
          results.add(res);
          matchedIndices.add(_Range(start, end));
        }
      }
    }

    // Pattern 1
    for (final match in pattern1.allMatches(text)) {
      final bookName = match.group(1)?.trim();
      final chapterStr = match.group(2);
      final verseStr = match.group(3);
      if (bookName != null && chapterStr != null && verseStr != null) {
        final chapter = int.tryParse(chapterStr);
        final verse = int.tryParse(verseStr);
        if (chapter != null && verse != null) {
          final res = lookupReference(bookName, chapter, verse);
          if (res != null) {
            addResult(res, match.start, match.end);
          }
        }
      }
    }

    // Pattern 2
    for (final match in pattern2.allMatches(text)) {
      if (overlaps(match.start, match.end)) continue;
      final bookName = match.group(1)?.trim();
      final chapterStr = match.group(2);
      if (bookName != null && chapterStr != null) {
        final chapter = int.tryParse(chapterStr);
        if (chapter != null) {
          final res = lookupReference(bookName, chapter, 1);
          if (res != null) {
            addResult(res, match.start, match.end);
          }
        }
      }
    }

    // Pattern 3
    for (final match in pattern3.allMatches(text)) {
      if (overlaps(match.start, match.end)) continue;
      final bookName = match.group(1)?.trim();
      final chapterStr = match.group(2);
      if (bookName != null && chapterStr != null) {
        final chapter = int.tryParse(chapterStr);
        if (chapter != null) {
          final bookIndex = findBookIndex(bookName);
          if (bookIndex != -1) {
            final res = lookupReference(bookName, chapter, 1);
            if (res != null) {
              addResult(res, match.start, match.end);
            }
          }
        }
      }
    }

    return results;
  }

  String bookLabel(int bookIndex, BibleViewMode mode) {
    final koreanName = korean.books[bookIndex].name;
    final englishName = english.books[bookIndex].name;

    switch (mode) {
      case BibleViewMode.korean:
        return koreanName;
      case BibleViewMode.english:
        return englishName;
      case BibleViewMode.parallel:
        return '$koreanName / $englishName';
    }
  }

  List<BibleSearchResult> search(
    String rawQuery,
    BibleViewMode mode, {
    int limit = 80,
  }) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return const [];
    }

    final results = <BibleSearchResult>[];

    for (var bookIndex = 0; bookIndex < bookCount; bookIndex++) {
      final koreanBook = korean.books[bookIndex];
      final englishBook = english.books[bookIndex];
      final chapterCount = min(
        koreanBook.chapters.length,
        englishBook.chapters.length,
      );

      for (var chapterIndex = 0; chapterIndex < chapterCount; chapterIndex++) {
        final koreanChapter = koreanBook.chapters[chapterIndex];
        final englishChapter = englishBook.chapters[chapterIndex];
        final verseCount = min(
          koreanChapter.verses.length,
          englishChapter.verses.length,
        );

        for (var verseIndex = 0; verseIndex < verseCount; verseIndex++) {
          final koreanVerse = koreanChapter.verses[verseIndex];
          final englishVerse = englishChapter.verses[verseIndex];
          final koreanText = koreanVerse.text;
          final englishText = englishVerse.text;

          final matchesKorean =
              mode != BibleViewMode.english &&
              koreanText.toLowerCase().contains(query);
          final matchesEnglish =
              mode != BibleViewMode.korean &&
              englishText.toLowerCase().contains(query);

          if (!matchesKorean && !matchesEnglish) {
            continue;
          }

          results.add(
            BibleSearchResult(
              bookIndex: bookIndex,
              chapterIndex: chapterIndex,
              verseIndex: verseIndex,
              koreanBookName: koreanBook.name,
              englishBookName: englishBook.name,
              chapter: koreanVerse.chapter,
              verse: koreanVerse.verse,
              koreanText: koreanText,
              englishText: englishText,
            ),
          );

          if (results.length >= limit) {
            return results;
          }
        }
      }
    }

    return results;
  }
}

class _Range {
  _Range(this.start, this.end);
  final int start;
  final int end;
}
