enum BibleViewMode { korean, english, parallel }

extension BibleViewModeLabel on BibleViewMode {
  String get label {
    switch (this) {
      case BibleViewMode.korean:
        return '한국어';
      case BibleViewMode.english:
        return 'English';
      case BibleViewMode.parallel:
        return '한영대조';
    }
  }
}

class BibleTranslation {
  BibleTranslation({
    required this.abbreviation,
    required this.translation,
    required this.language,
    required this.license,
    required this.source,
    required this.books,
  });

  final String abbreviation;
  final String translation;
  final String language;
  final String license;
  final String source;
  final List<BibleBook> books;

  factory BibleTranslation.fromJson(Map<String, dynamic> json) {
    return BibleTranslation(
      abbreviation: json['abbreviation'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      language: json['language'] as String? ?? '',
      license: json['distribution_license'] as String? ?? '',
      source: json['distribution_source'] as String? ?? '',
      books: (json['books'] as List<dynamic>? ?? [])
          .map((book) => BibleBook.fromJson(book as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BibleBook {
  BibleBook({required this.number, required this.name, required this.chapters});

  final int number;
  final String name;
  final List<BibleChapter> chapters;

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      number: _toInt(json['nr']),
      name: json['name'] as String? ?? '',
      chapters: (json['chapters'] as List<dynamic>? ?? [])
          .map(
            (chapter) => BibleChapter.fromJson(chapter as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class BibleChapter {
  BibleChapter({
    required this.number,
    required this.name,
    required this.verses,
  });

  final int number;
  final String name;
  final List<BibleVerse> verses;

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    return BibleChapter(
      number: _toInt(json['chapter']),
      name: json['name'] as String? ?? '',
      verses: (json['verses'] as List<dynamic>? ?? [])
          .map((verse) => BibleVerse.fromJson(verse as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BibleVerse {
  BibleVerse({
    required this.chapter,
    required this.verse,
    required this.name,
    required this.text,
  });

  final int chapter;
  final int verse;
  final String name;
  final String text;

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      chapter: _toInt(json['chapter']),
      verse: _toInt(json['verse']),
      name: json['name'] as String? ?? '',
      text: (json['text'] as String? ?? '').trim(),
    );
  }
}

class BibleSearchResult {
  BibleSearchResult({
    required this.bookIndex,
    required this.chapterIndex,
    required this.verseIndex,
    required this.koreanBookName,
    required this.englishBookName,
    required this.chapter,
    required this.verse,
    required this.koreanText,
    required this.englishText,
  });

  final int bookIndex;
  final int chapterIndex;
  final int verseIndex;
  final String koreanBookName;
  final String englishBookName;
  final int chapter;
  final int verse;
  final String koreanText;
  final String englishText;
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
