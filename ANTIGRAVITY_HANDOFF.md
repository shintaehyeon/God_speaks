# Antigravity Handoff - HISpeak

## Repository
https://github.com/shintaehyeon/God_speaks
Branch: `main`
Commit: `7b28eba`

App name: HISpeak
Meaning: 그의 음성 (His voice)

---

## 🚀 Recently Completed Features (Commit: 7b28eba)

### 1. Offline Bible Verse Reference Detection
- **Path**: `lib/services/bible_repository.dart` ➔ `BibleLibrary.parseReferences()`
- **Details**: Implemented a RegExp-based parser that scans transcription text to detect direct scripture references (e.g., `요한복음 3장 16절`, `요 3:16`, `John 3:16`, `Romans 8`).
- **Overlap Protection**: Matched indices are tracked via a helper class `_Range` to ensure shorter chapter-only patterns do not duplicate or corrupt longer chapter-and-verse matches on the same text.
- **Bilingual Lookup**: Resolves references instantly from local JSON assets (`assets/bibles/korean.json` and `web.json`) without querying external APIs.

### 2. Semantic Verse Recommendation Fallback
- **Path**: `lib/state/sermon_provider.dart` ➔ `getSemanticVerseRecommendations()`
- **Details**: If no direct bible references are detected in the transcript, the app invokes Gemini to recommend 1-2 relevant passages. It cleans the response and resolves their text locally.

### 3. Premium 5-Field AI Sermon Summary Card
- **Path**: `lib/models/sermon_summary.dart`, `lib/home.dart`, `lib/summaries.dart`
- **Details**: Overhauled the summary representation to include:
  1. **Main Topic (핵심 주제)**: Prominent title of the summary.
  2. **Key Bible Passage (관련 성경 본문)**: Side-by-side or stacked Korean/English verse text in a styled quotes card.
  3. **Short Summary (설교 요약)**: 3 clear bullet points.
  4. **Application Points (적용점)**: 2-3 points with green check icons.
  5. **Prayer Points (기도 제목)**: 2-3 points with pink heart icons.
- **Firebase Sync**: The new fields (`keyScriptureTextKor`, `keyScriptureTextEng`, `applicationPoints`, `prayerPoints`) are written to Firestore summaries collection.
- **Demo Fallback**: In simulation/demo mode, a mock summary matching this 5-field premium card is constructed using resolved Psalm 23:1 data.

### 4. Rebranding footer
- **Path**: `lib/splash.dart`
- **Details**: Updated the splash screen footer from `POWERED BY SOLOMON AI ENGINE` to `POWERED BY GOD SPEAKS AI ENGINE`.

---

## 🧪 Testing and Quality Control

### Unit Tests
- New test suite added: [bible_parse_test.dart](file:///Users/sintaehyeon/mobile%20app_project_personal_final/test/bible_parse_test.dart)
- Validated book mapping, abbreviation lookups, direct Korean/English parser, chapter-only defaults, and non-scripture ignores.
- All 8 unit tests compile and pass successfully (`flutter test`).

### Analyze
- Checked with `flutter analyze` and verified zero compiling errors or warning blockers in new files.

---

## 🔮 Next Steps & Tasks to Work On

When you resume this project, focus on the following tasks:

### 1. Live Integration End-to-End Test
- Turn on `useRealAI` in settings, mount a real microphone, and run `flutter run`.
- Speak Korean/English to verify STT acceptance, Gemini translation accuracy, and final JSON parsing inside `_stopLiveTranslation()`.

### 2. Audio Player integration
- The play button (`Listen`) on the summary card is currently a mock snackbar.
- Add an audio player package (like `audioplayers`) to play real mp3 files or record and play back sermon audio clips.

### 3. Archive Screen Premium UI Alignment
- The Archive screen (`lib/archive.dart`) currently renders simple saved item lists. Align the layout of archived verses to use the newly implemented premium quote container with bilingual parallel scripture blocks.
