import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_final/models/bible.dart';
import 'package:mobile_app_final/services/bible_repository.dart';

void main() {
  late BibleLibrary library;

  setUp(() {
    final korean = BibleTranslation.fromJson(
      jsonDecode(File('assets/bibles/korean.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final english = BibleTranslation.fromJson(
      jsonDecode(File('assets/bibles/web.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    library = BibleLibrary(korean: korean, english: english);
  });

  group('Bible Reference Parsing & Lookup Tests', () {
    test('standard book abbreviations build successfully', () {
      expect(library.bookNameToIndex.containsKey('요한복음'), isTrue);
      expect(library.bookNameToIndex.containsKey('요'), isTrue);
      expect(library.bookNameToIndex.containsKey('john'), isTrue);
      expect(library.bookNameToIndex.containsKey('jn'), isTrue);
      expect(library.bookNameToIndex.containsKey('창'), isTrue);
      expect(library.bookNameToIndex.containsKey('genesis'), isTrue);
    });

    test('lookupReference resolves exact book chapter and verse', () {
      final john316 = library.lookupReference('John', 3, 16);
      expect(john316, isNotNull);
      expect(john316!.koreanBookName, '요한복음');
      expect(john316.englishBookName, 'John');
      expect(john316.chapter, 3);
      expect(john316.verse, 16);
      expect(john316.koreanText, contains('독생자'));
      expect(john316.englishText, contains('one and only Son'));
    });

    test('parseReferences parses Korean direct references correctly', () {
      final results1 = library.parseReferences('요한복음 3장 16절 말씀입니다.');
      expect(results1, hasLength(1));
      expect(results1.first.englishBookName, 'John');
      expect(results1.first.chapter, 3);
      expect(results1.first.verse, 16);

      final results2 = library.parseReferences('오늘 구절은 요 3:16 입니다.');
      expect(results2, hasLength(1));
      expect(results2.first.englishBookName, 'John');
      expect(results2.first.chapter, 3);
      expect(results2.first.verse, 16);
    });

    test('parseReferences parses English direct references correctly', () {
      final results1 = library.parseReferences('For God so loved the world, see John 3:16.');
      expect(results1, hasLength(1));
      expect(results1.first.englishBookName, 'John');
      expect(results1.first.chapter, 3);
      expect(results1.first.verse, 16);

      final results2 = library.parseReferences('Check out Rom 8:28.');
      expect(results2, hasLength(1));
      expect(results2.first.englishBookName, 'Romans');
      expect(results2.first.chapter, 8);
      expect(results2.first.verse, 28);
    });

    test('parseReferences handles chapter-only references gracefully', () {
      final results = library.parseReferences('Let us meditate on Romans 8.');
      expect(results, hasLength(1));
      expect(results.first.englishBookName, 'Romans');
      expect(results.first.chapter, 8);
      expect(results.first.verse, 1); // Defaults to verse 1
    });

    test('parseReferences ignores non-bible numbers and text', () {
      final results = library.parseReferences('오늘 날씨는 25도이고 회의는 3시에 시작합니다.');
      expect(results, isEmpty);
    });
  });
}
