import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_final/models/bible.dart';
import 'package:mobile_app_final/services/bible_repository.dart';

void main() {
  test('bundled Korean and English bibles parse and align', () {
    final korean = BibleTranslation.fromJson(
      jsonDecode(File('assets/bibles/korean.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final english = BibleTranslation.fromJson(
      jsonDecode(File('assets/bibles/web.json').readAsStringSync())
          as Map<String, dynamic>,
    );

    expect(korean.license, 'Public Domain');
    expect(english.license, 'Public Domain');
    expect(korean.books, hasLength(66));
    expect(english.books, hasLength(66));

    final john316Korean = korean.books[42].chapters[2].verses[15];
    final john316English = english.books[42].chapters[2].verses[15];

    expect(korean.books[42].name, '요한복음');
    expect(english.books[42].name, 'John');
    expect(john316Korean.name, '요한복음 3:16');
    expect(john316English.name, 'John 3:16');
    expect(john316Korean.text, contains('독생자'));
    expect(john316English.text, contains('one and only Son'));

    final library = BibleLibrary(korean: korean, english: english);
    final results = library.search('one and only Son', BibleViewMode.parallel);

    expect(
      results.any(
        (result) =>
            result.englishBookName == 'John' &&
            result.chapter == 3 &&
            result.verse == 16,
      ),
      isTrue,
    );
  });
}
