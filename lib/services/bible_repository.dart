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
  BibleLibrary({required this.korean, required this.english});

  final BibleTranslation korean;
  final BibleTranslation english;

  int get bookCount => min(korean.books.length, english.books.length);

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
