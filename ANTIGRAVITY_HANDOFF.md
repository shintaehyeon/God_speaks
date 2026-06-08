# Antigravity Handoff

## Repository

https://github.com/shintaehyeon/God_speaks

## Run

```bash
git clone https://github.com/shintaehyeon/God_speaks.git
cd God_speaks
flutter pub get
flutter test
flutter run
```

For web:

```bash
flutter run -d chrome
```

## Current Bible Feature

- Korean Bible data: `assets/bibles/korean.json`
- English Bible data: `assets/bibles/web.json`
- Reader UI: `lib/bible_page.dart`
- Bible model: `lib/models/bible.dart`
- Bible loader/search: `lib/services/bible_repository.dart`
- Bottom navigation entry: `lib/main_navigation.dart`
- Data test: `test/bible_data_test.dart`

The Korean Bible text is Korean Revised Version 1952/1961 from Wikisource via GetBible and is marked Public Domain. It is not the Korean Revised New Version.

The English Bible text is World English Bible via GetBible and is marked Public Domain.

## Prompt For Antigravity

Continue this Flutter project as a bilingual sermon companion app.

The app already has an offline bilingual Bible reader using bundled Public Domain data:

- Korean: `assets/bibles/korean.json`
- English WEB: `assets/bibles/web.json`
- Reader screen: `lib/bible_page.dart`
- Search/data loader: `lib/services/bible_repository.dart`

Next, implement sermon intelligence in this order:

1. In the live sermon flow, keep STT in the original spoken language.
   - If the sermon is Korean, transcribe Korean first, then translate to English with Gemini.
   - If the sermon is English, transcribe English first, then translate to Korean with Gemini.

2. Add Bible reference detection.
   - Detect direct references like `요한복음 3장 16절`, `요 3:16`, `John 3:16`, and `Romans 8`.
   - Use the bundled Bible data to fetch matched Korean/English verses.
   - Do not call paid Bible APIs for the MVP.

3. Add semantic related-verse suggestions with Gemini.
   - When there is no direct reference, ask Gemini for likely Bible passages related to the sermon transcript.
   - Normalize Gemini output into book/chapter/verse references.
   - Fetch the actual verse text from the bundled local Bible data.

4. Add a sermon summary card.
   - Main topic
   - Key Bible passage
   - Short summary
   - Application points
   - Prayer points

5. Keep copyright safety.
   - Do not add NIV, ESV, NLT, Korean Revised New Version, or other copyrighted Bible texts unless a license is provided.
   - Keep the current Public Domain KorRV/WEB data for the free MVP.

Before finishing, run:

```bash
flutter pub get
flutter test
flutter analyze
```

Note: `flutter analyze` currently reports existing info-level warnings in older project files. Do not treat those as blockers unless new errors are introduced.
