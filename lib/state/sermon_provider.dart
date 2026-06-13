import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/sermon_summary.dart';
import '../models/saved_item.dart';
import '../models/sermon_flow.dart';
import '../models/bible.dart';
import '../services/bible_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SermonProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BibleRepository _bibleRepository = BibleRepository();
  BibleLibrary? _bibleLibrary;
  BibleLibrary? get bibleLibrary => _bibleLibrary;

  User? _user;
  User? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Global Navigation Tab Index
  int _currentNavigationIndex = 0;
  int get currentNavigationIndex => _currentNavigationIndex;
  
  void setNavigationIndex(int index) {
    if (_currentNavigationIndex != index) {
      _currentNavigationIndex = index;
      notifyListeners();
    }
  }

  // Real-time AI Configuration
  bool _useRealAI = false;
  bool get useRealAI => _useRealAI;
  bool _isEnglishToKorean = false;
  bool get isEnglishToKorean => _isEnglishToKorean;

  // Advanced AI and Speech Engines
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  double _currentSoundLevel = 0.0;
  GenerativeModel? _geminiModel;
  String _accumulatedKoreanText = ""; // For summarizing at the end
  String _rawSpeechTranscriptText = "";
  String _lastCommittedSpeechText = "";
  String _todaySermonSummary = "";
  String _todaySermonTranscript = "";
  String get todaySermonSummary => _todaySermonSummary;
  String get todaySermonTranscript => _todaySermonTranscript;
  bool get hasTodaySermonSummary => _todaySermonSummary.trim().isNotEmpty;

  String _todaySermonTitle = "";
  String get todaySermonTitle => _todaySermonTitle;
  String _todaySermonCategory = "";
  String get todaySermonCategory => _todaySermonCategory;
  String _todaySermonKeyScripture = "";
  String get todaySermonKeyScripture => _todaySermonKeyScripture;
  String _todaySermonKeyScriptureTextKor = "";
  String get todaySermonKeyScriptureTextKor => _todaySermonKeyScriptureTextKor;
  String _todaySermonKeyScriptureTextEng = "";
  String get todaySermonKeyScriptureTextEng => _todaySermonKeyScriptureTextEng;
  List<String> _todaySermonBulletPoints = [];
  List<String> get todaySermonBulletPoints => _todaySermonBulletPoints;
  List<String> _todaySermonApplicationPoints = [];
  List<String> get todaySermonApplicationPoints => _todaySermonApplicationPoints;
  List<String> _todaySermonPrayerPoints = [];
  List<String> get todaySermonPrayerPoints => _todaySermonPrayerPoints;

  String _todaySummaryDocId = "";
  String get todaySummaryDocId => _todaySummaryDocId;
  String _todaySermonUserComment = "";
  String get todaySermonUserComment => _todaySermonUserComment;

  // User Preferences from Firestore
  String _displayName = "Alex Johnson";
  String get displayName => _displayName;
  String _userRole = "성도 (Member)";
  String get userRole => _userRole;
  String _translationLanguage = "English";
  String get translationLanguage => _translationLanguage;
  String _appearance = "Light Mode";
  String get appearance => _appearance;
  bool _pushNotifications = true;
  bool get pushNotifications => _pushNotifications;
  String _preferredBibleVersion = "NIV";
  String get preferredBibleVersion => _preferredBibleVersion;
  String? _profileImagePath;
  String? get profileImagePath => _profileImagePath;
  bool _hasSeenTutorial = false;
  bool get hasSeenTutorial => _hasSeenTutorial;

  String _customGeminiApiKey = "";
  String get customGeminiApiKey => _customGeminiApiKey;

  int _translationCount = 0;
  int get translationCount => _translationCount;
  bool get isGuestLimitExceeded => false; // Temporarily unlocked to unlimited for guest demo!

  // Real-time Translation State
  bool _isRecording = false;
  bool get isRecording => _isRecording;
  String _selectedLocation = "본당"; // '본당', '한동대학교 대강당', '소예배실'
  String get selectedLocation => _selectedLocation;
  String _selectedTranslationMode = "자막 모드"; // '자막 모드', '요약 모드', '인용 추출'
  String get selectedTranslationMode => _selectedTranslationMode;

  // Active translation session content
  String _liveTranslationText = "";
  String get liveTranslationText => _liveTranslationText;
  List<SermonFlowStep> _sermonFlowSteps = [];
  List<SermonFlowStep> get sermonFlowSteps => _sermonFlowSteps;

  // Audio wave values for visualizer animation
  List<double> _waveValues = List.filled(15, 0.1);
  List<double> get waveValues => _waveValues;

  // Data lists from Firestore
  List<SermonSummary> _summaries = [];
  List<SermonSummary> get summaries => _summaries;

  List<SavedItem> _archiveItems = [];
  List<SavedItem> get archiveItems => _archiveItems;

  Set<String> _savedItemIds = {};
  Set<String> get savedItemIds => _savedItemIds;

  Timer? _translationTimer;
  Timer? _waveTimer;
  int _simulationSeconds = 0;

  bool _isOffline = false;
  bool get isOffline => _isOffline;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  SermonProvider() {
    _auth.authStateChanges().listen((User? u) {
      _user = u;
      if (u != null) {
        _loadUserProfile();
        _listenToSummaries();
        _listenToArchiveItems();
        _listenToSavedUserItems();
      } else {
        _resetState();
      }
      notifyListeners();
    });

    _initConnectivity();
    _loadBibleLibrary();
  }

  Future<void> _loadBibleLibrary() async {
    try {
      _bibleLibrary = await _bibleRepository.loadLibrary();
      notifyListeners();
    } catch (e) {
      print("Error loading bible library in SermonProvider: $e");
    }
  }

  Future<List<BibleSearchResult>> getSemanticVerseRecommendations(
    String transcript,
  ) async {
    if (_geminiModel == null || _bibleLibrary == null) return [];

    final prompt = """
You are a sermon assistant. Based on the following sermon transcript, recommend 1 or 2 most relevant Bible passages.
Provide the response strictly as a JSON array of strings containing the book and chapter/verse, for example:
["John 3:16", "Romans 8:28"] or ["Psalm 23:1"].
Do not add any explanations, introductory text, markdown formatting, or code block markers. Just return the raw JSON array.

Sermon Transcript:
"$transcript"
""";

    try {
      final response = await _geminiModel!.generateContent([Content.text(prompt)]);
      final responseText = response.text?.trim() ?? "";
      if (responseText.isEmpty) return [];

      String cleanJson = responseText;
      if (cleanJson.startsWith("```")) {
        final lines = cleanJson.split("\n");
        if (lines.first.startsWith("```")) {
          lines.removeAt(0);
        }
        if (lines.isNotEmpty && lines.last.startsWith("```")) {
          lines.removeLast();
        }
        cleanJson = lines.join("\n").trim();
      }

      final List<dynamic> parsed = jsonDecode(cleanJson);
      final List<BibleSearchResult> results = [];
      for (final ref in parsed) {
        if (ref is String) {
          final verses = _bibleLibrary!.parseReferences(ref);
          if (verses.isNotEmpty) {
            results.addAll(verses);
          }
        }
      }
      return results;
    } catch (e) {
      print("Semantic verse recommendation error: $e");
      return [];
    }
  }

  void _initConnectivity() {
    // Check initial connection
    Connectivity().checkConnectivity().then((List<ConnectivityResult> results) {
      bool offline =
          results.isEmpty || results.contains(ConnectivityResult.none);
      if (_isOffline != offline) {
        _isOffline = offline;
        notifyListeners();
      }
    });

    // Listen to changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      bool offline =
          results.isEmpty || results.contains(ConnectivityResult.none);
      if (_isOffline != offline) {
        _isOffline = offline;
        notifyListeners();
      }
    });
  }

  void _resetState() {
    _summaries.clear();
    _archiveItems.clear();
    _savedItemIds.clear();
    _stopLiveTranslation();
  }

  // 1. User Profile Setup & Update
  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _displayName = data['displayName'] ?? "Alex Johnson";
        _userRole = data['userRole'] ?? "성도 (Member)";
        _translationLanguage = data['translationLanguage'] ?? "English";
        _appearance = data['appearance'] ?? "Light Mode";
        _pushNotifications = data['pushNotifications'] ?? true;
        _preferredBibleVersion = data['preferredBibleVersion'] ?? "NIV";
        _useRealAI = data['useRealAI'] ?? false;
        _translationCount = data['translationCount'] ?? 0;
        _profileImagePath = data['profileImagePath'];
        _hasSeenTutorial = data['hasSeenTutorial'] ?? false;
        
        // [VIDEO RECORDING MODE] Force tutorial to always show for video recording!
        _hasSeenTutorial = false;
        
        _customGeminiApiKey = data['geminiApiKey'] ?? "";
        if (!_hasSeenTutorial) {
          _showTutorial = true; // Trigger tutorial only if never seen
        } else {
          _showTutorial = false;
        }
      } else {
        // Create user document with defaults
        await _firestore.collection('users').doc(_user!.uid).set({
          'displayName': _displayName,
          'userRole': _userRole,
          'translationLanguage': _translationLanguage,
          'appearance': _appearance,
          'pushNotifications': _pushNotifications,
          'preferredBibleVersion': _preferredBibleVersion,
          'useRealAI': _useRealAI,
          'translationCount': 0,
          'profileImagePath': null,
          'hasSeenTutorial': false,
          'geminiApiKey': '',
          'email': _user!.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _translationCount = 0;
        _showTutorial = true; // New users always get the tutorial
      }
      notifyListeners();
    } catch (e) {
      print("Error loading user profile: $e");
    }
  }

  Future<void> updateUserPreference({
    String? translationLanguage,
    String? appearance,
    bool? pushNotifications,
    String? preferredBibleVersion,
    String? displayName,
    bool? useRealAI,
    String? profileImagePath,
    bool? hasSeenTutorial,
    String? geminiApiKey,
  }) async {
    if (_user == null) return;
    try {
      Map<String, dynamic> updates = {};
      if (translationLanguage != null) {
        _translationLanguage = translationLanguage;
        updates['translationLanguage'] = translationLanguage;
      }
      if (appearance != null) {
        _appearance = appearance;
        updates['appearance'] = appearance;
      }
      if (pushNotifications != null) {
        _pushNotifications = pushNotifications;
        updates['pushNotifications'] = pushNotifications;
      }
      if (preferredBibleVersion != null) {
        _preferredBibleVersion = preferredBibleVersion;
        updates['preferredBibleVersion'] = preferredBibleVersion;
      }
      if (displayName != null) {
        _displayName = displayName;
        updates['displayName'] = displayName;
      }
      if (useRealAI != null) {
        _useRealAI = useRealAI;
        updates['useRealAI'] = useRealAI;
      }
      if (profileImagePath != null) {
        _profileImagePath = profileImagePath;
        updates['profileImagePath'] = profileImagePath;
      }
      if (hasSeenTutorial != null) {
        _hasSeenTutorial = hasSeenTutorial;
        updates['hasSeenTutorial'] = hasSeenTutorial;
      }
      if (geminiApiKey != null) {
        _customGeminiApiKey = geminiApiKey;
        updates['geminiApiKey'] = geminiApiKey;
      }

      // Optimistic UI update: instantly reflect changes on screen (e.g. Dark Mode)
      notifyListeners();

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_user!.uid).update(updates);
      }
    } catch (e) {
      print("Error updating preferences: $e");
    }
  }

  // 2. Real-time Live Translation Session Controls
  void toggleLanguageDirection() {
    _isEnglishToKorean = !_isEnglishToKorean;
    _translationLanguage = _isEnglishToKorean ? "Korean" : "English";
    notifyListeners();
  }

  void setLocation(String loc) {
    _selectedLocation = loc;
    notifyListeners();
  }

  void setTranslationMode(String mode) {
    _selectedTranslationMode = mode;
    notifyListeners();
  }

  void toggleRecording() {
    if (_isRecording) {
      _stopLiveTranslation();
    } else {
      _startLiveTranslation();
    }
  }

  // AI Toggle setter
  void toggleRealAI(bool value) {
    _useRealAI = value;
    updateUserPreference(useRealAI: value);
    notifyListeners();
  }

  void _startLiveTranslation() async {
    incrementTranslationCount();
    _isRecording = true;
    _accumulatedKoreanText = "";
    _rawSpeechTranscriptText = "";
    _lastCommittedSpeechText = "";
    _todaySummaryDocId = "";
    _todaySermonUserComment = "";
    _sermonFlowSteps = [];
    notifyListeners();

    // 1. REAL AI MODE ACTIVE
    if (_useRealAI) {
      _liveTranslationText = "실시간 AI 음성 인식 엔진 및 번역기 초기화 중...";
      notifyListeners();

      try {
        // Initialize Speech-to-Text
        _speechInitialized = await _speech.initialize(
          onStatus: (status) {
            print("STT Status: $status");
            if (status == 'done' || status == 'notListening') {
              // Automatically restart listening if still recording to simulate continuous listening
              if (_isRecording) _startSpeechListening();
            }
          },
          onError: (errorNotification) {
            print("STT Error: $errorNotification");
            // If mic permission fails or STT not supported, fallback gracefully to simulation
            if (_isRecording) {
              _switchToSimulationFallback(
                "마이크 연결 상태 또는 권한 부족으로 인해 안전 시뮬레이션 모드로 전환되었습니다.",
              );
            }
          },
        );

        if (_speechInitialized) {
          _liveTranslationText = "마이크가 활성화되었습니다. 한국어로 설교를 말씀하세요...";

          // Build Gemini Model (Free tier support)
          // Injected user's actual API key directly for seamless out-of-the-box operation!
          final geminiApiKey = _customGeminiApiKey.trim().isNotEmpty
              ? _customGeminiApiKey.trim()
              : const String.fromEnvironment(
                  'GEMINI_API_KEY',
                  defaultValue: 'AIzaSyBKB3_goai6MVnA5uQ89_BJyg9jCAVo1Uk',
                );
          _geminiModel = GenerativeModel(
            model: 'gemini-2.5-flash',
            apiKey: geminiApiKey,
          );

          _startSpeechListening();

          // Smooth real-time microphone sound level wave animation
          _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (
            timer,
          ) {
            final rand = Random();
            if (_speech.isListening && _useRealAI) {
              // Real AI voice dynamics: wave only rolls vigorously when actual sound level is high!
              // When silent, _currentSoundLevel is low, making it quiet and calm.
              // Normalize decibel/sound level smoothly to factor (typically -2dB to 10dB or 0-10 scale)
              double soundFactor = (_currentSoundLevel / 10.0).clamp(0.02, 1.0);
              // Make wave nodes bounce proportionally to the real sound input level
              _waveValues = List.generate(
                15,
                (index) => soundFactor * (rand.nextDouble() * 0.85 + 0.15),
              );
            } else if (_isRecording && !_useRealAI) {
              // Simulation Demo Mode: simulate standard beautiful waves
              double simulatedVolume = rand.nextDouble() * 0.6 + 0.4;
              _waveValues = List.generate(
                15,
                (index) => simulatedVolume * (rand.nextDouble() * 0.7 + 0.3),
              );
            } else {
              _waveValues = List.generate(
                15,
                (index) => rand.nextDouble() * 0.04 + 0.01,
              ); // completely flat/calm when stopped
            }
            notifyListeners();
          });
        } else {
          _switchToSimulationFallback(
            "음성 인식 시스템 초기화에 실패하여 안전 데모 모드로 자동 전환되었습니다.",
          );
        }
      } catch (e) {
        print("Real AI initialization error: $e");
        _switchToSimulationFallback("네트워크 또는 장치 오류로 인해 시뮬레이션 모드로 안전 전환되었습니다.");
      }
    }
    // 2. SIMULATION MOCK MODE ACTIVE
    else {
      _liveTranslationText =
          "Establishing connection to audio stream in $_selectedLocation...";
      _simulationSeconds = 0;

      // Wave simulation timer
      _waveTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        final rand = Random();
        _waveValues = List.generate(
          15,
          (index) => rand.nextDouble() * 0.9 + 0.1,
        );
        notifyListeners();
      });

      // Shorter, bilingual stream texts for extremely quick simulation (4.5s total)
      const streamTexts = [
        "여호와는 나의 목자시니 내게 부족함이 없으리로다. (The Lord is my shepherd, I shall not want.)",
        " 내가 사망의 음침한 골짜기로 다닐지라도 해를 두려워하지 않을 것은 주께서 나와 함께 하심이라. (Even though I walk through the valley of the shadow of death, I will fear no evil.)",
        " 주의 지팡이와 막대기가 나를 안위하시나이다. (Your rod and your staff, they comfort me.)",
      ];

      _translationTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        _simulationSeconds += 2; // Increments by 2 simulated units per tick
        int index = (_simulationSeconds ~/ 2) - 1;

        if (index < streamTexts.length) {
          if (index == 0) {
            _liveTranslationText = streamTexts[0];
          } else {
            _liveTranslationText = "$_liveTranslationText\n\n${streamTexts[index]}";
          }
          _accumulatedKoreanText = _liveTranslationText.trim();
        }

        // Add topic flow at tick 1 (after 2 seconds)
        if (_simulationSeconds == 2) {
          _sermonFlowSteps.add(
            SermonFlowStep(
              time: "10:15 AM",
              type: "topic",
              title: "주제: 말씀의 성취와 삶의 열매",
              description: "선포된 말씀이 좋은 밭에 떨어져 100배의 결실을 맺기를 소망합니다...",
            ),
          );
        }

        // Add scripture flow at tick 2 (after 4 seconds)
        if (_simulationSeconds == 4) {
          _sermonFlowSteps.add(
            SermonFlowStep(
              time: "12:45 PM",
              type: "scripture",
              title: "시편 23:1 (Psalm 23:1)",
              description: "\"여호와는 나의 목자시니 내게 부족함이 없으리로다.\"",
            ),
          );
        }

        // Add concluding flow at tick 3 (after 4.5 seconds)
        if (_simulationSeconds == 6) {
          _sermonFlowSteps.add(
            SermonFlowStep(
              time: "진행 중...",
              type: "pending",
              title: "결론: 소망의 확신 (Assurance of Hope)",
              description: "소망은 신성한 타이밍을 신뢰하는 지속적인 선택입니다.",
            ),
          );
        }

        notifyListeners();
      });
    }

    notifyListeners();
  }

  void _startSpeechListening() {
    if (!_isRecording || !_speechInitialized) return;

    _speech.listen(
      onResult: (result) async {
        if (result.recognizedWords.isNotEmpty) {
          final newWords = result.recognizedWords.trim();
          String displayText = newWords;

          // Translate in real-time using super-fast Gemini AI
          if (_geminiModel != null) {
            try {
              final translationPrompt = _isEnglishToKorean
                  ? "You are a professional sermon translator. Translate the following English spoken sentence into natural, graceful, and holy Korean for a sermon transcription. Do not include any explanations, just provide the direct Korean translation. Sentence: \"$newWords\""
                  : "You are a professional sermon translator. Translate the following Korean spoken sentence into natural, graceful, and holy English for a sermon transcription. Do not include any explanations, just provide the direct English translation. Sentence: \"$newWords\"";
              final response = await _geminiModel!.generateContent([
                Content.text(translationPrompt),
              ]);
              if (response.text != null && _isRecording) {
                String translated = response.text!.trim();
                // Strip any surrounding quotes
                if (translated.startsWith('"') && translated.endsWith('"')) {
                  translated = translated.substring(1, translated.length - 1);
                }
                displayText = translated;
              }
            } catch (e) {
              print("Gemini translation error: $e");
            }
          }

          _liveTranslationText = _joinTranscriptLines(
            _accumulatedKoreanText,
            displayText,
          );

          if (result.finalResult && newWords != _lastCommittedSpeechText) {
            _rawSpeechTranscriptText = _joinTranscriptLines(
              _rawSpeechTranscriptText,
              newWords,
            );
            _accumulatedKoreanText = _joinTranscriptLines(
              _accumulatedKoreanText,
              displayText,
            );
            _lastCommittedSpeechText = newWords;
            _liveTranslationText = _accumulatedKoreanText;
          }

          // ── 키워드 기반 주제 카드 자동 생성 (Real AI 모드) ──
          // 주제 카드는 최초 1회만 추가 (중복 방지)
          bool hasTopic = _sermonFlowSteps.any((s) => s.type == 'topic');
          if (!hasTopic) {
            String detectedTitle = '';
            String detectedDesc = '';
            final allText = '$_accumulatedKoreanText $newWords';

            if (allText.contains('믿음') ||
                allText.contains('시련') ||
                allText.contains('고난')) {
              detectedTitle = '주제: 믿음의 시련을 이기는 소망';
              detectedDesc = '고난 속에서 낙심하지 않고 하나님의 더 크신 섭리를 바라봅니다...';
            } else if (allText.contains('사랑') ||
                allText.contains('이웃') ||
                allText.contains('형제')) {
              detectedTitle = '주제: 그리스도의 사랑으로 하나 됨';
              detectedDesc = '하나님이 우리를 먼저 사랑하셨기에 마땅히 형제를 사랑해야 합니다...';
            } else if (allText.contains('은혜') ||
                allText.contains('십자가') ||
                allText.contains('보혈')) {
              detectedTitle = '주제: 십자가의 은혜와 구원의 소망';
              detectedDesc = '아무 자격 없으나 오직 값없는 은혜로 구원받았습니다...';
            } else if (allText.trim().length > 15) {
              // 키워드 없이 어느 정도 말이 쌓이면 기본 주제 카드 표시
              detectedTitle = '주제: 말씀의 성취와 삶의 열매';
              detectedDesc = '선포된 말씀이 좋은 밭에 떨어져 100배의 결실을 맺기를 소망합니다...';
            }

            if (detectedTitle.isNotEmpty) {
              final now = DateTime.now();
              final timeStr =
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
              _sermonFlowSteps.add(
                SermonFlowStep(
                  time: timeStr,
                  type: 'topic',
                  title: detectedTitle,
                  description: detectedDesc,
                ),
              );
            }
          }

          // 성경 구절 키워드 감지 (scripture 카드, 최초 1회)
          if (newWords.contains('시편') ||
              newWords.contains('성경') ||
              newWords.contains('Psalm') ||
              newWords.contains('요한') ||
              newWords.contains('로마') ||
              newWords.contains('고린도') ||
              newWords.contains('잠언') ||
              newWords.contains('이사야')) {
            bool hasScripture = _sermonFlowSteps.any(
              (s) => s.type == 'scripture',
            );
            if (!hasScripture) {
              final now = DateTime.now();
              final timeStr =
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
              _sermonFlowSteps.add(
                SermonFlowStep(
                  time: timeStr,
                  type: 'scripture',
                  title: '실시간 성경 감지 (Scripture Detected)',
                  description:
                      '"${newWords.length > 40 ? newWords.substring(0, 40) + '...' : newWords}"',
                ),
              );
            }
          }
          notifyListeners();
        }
      },
      localeId: _isEnglishToKorean ? 'en_US' : 'ko_KR',
      onSoundLevelChange: (level) {
        _currentSoundLevel = level.abs();
        notifyListeners();
      },
    );
  }

  String _joinTranscriptLines(String existing, String next) {
    final cleanExisting = existing.trim();
    final cleanNext = next.trim();
    if (cleanNext.isEmpty) return cleanExisting;
    if (cleanExisting.isEmpty) return cleanNext;
    return "$cleanExisting\n\n$cleanNext";
  }

  void _switchToSimulationFallback(String warningMessage) {
    print("Switching to simulation fallback: $warningMessage");
    _useRealAI = false;
    _speech.stop();
    _waveTimer?.cancel();
    _translationTimer?.cancel();

    // Smoothly reset stream context to simulation
    _startLiveTranslation();
    _liveTranslationText = "[$warningMessage]\n\n" + _liveTranslationText;
    notifyListeners();
  }

  void _stopLiveTranslation() async {
    _isRecording = false;
    _speech.stop();
    _waveTimer?.cancel();
    _translationTimer?.cancel();
    _waveValues = List.filled(15, 0.1);

    final translatedTranscript = _accumulatedKoreanText.trim().isNotEmpty
        ? _accumulatedKoreanText.trim()
        : _liveTranslationText.trim();
    final rawTranscript = _rawSpeechTranscriptText.trim();

    if (translatedTranscript.isNotEmpty &&
        !translatedTranscript.contains("마이크가 활성화되었습니다")) {
      _todaySermonTranscript = translatedTranscript;

      // Default fields in case of errors/fallbacks
      String title = '오늘의 실시간 STT 설교 요약';
      String category = 'LIVE STT';
      List<String> summaryPoints = ['실시간 음성으로 인식된 설교 메시지입니다.'];
      String keyScripture = '';
      String keyScriptureTextKor = '';
      String keyScriptureTextEng = '';
      List<String> appPoints = ['오늘 선포된 말씀을 묵상하고 삶의 자리에서 실천합시다.'];
      List<String> prayerPoints = ['선포된 말씀이 내 삶의 인도자가 되게 하소서.'];

      // Scripture detection
      final List<BibleSearchResult> resolvedScriptures = [];
      if (_bibleLibrary != null) {
        resolvedScriptures.addAll(_bibleLibrary!.parseReferences(translatedTranscript));
        if (rawTranscript.isNotEmpty) {
          resolvedScriptures.addAll(_bibleLibrary!.parseReferences(rawTranscript));
        }
      }

      // 1. REAL AI MODE ACTIVE
      if (_useRealAI && _geminiModel != null) {
        // If no direct reference is found, call semantic verse recommendation
        if (resolvedScriptures.isEmpty) {
          try {
            final recommended = await getSemanticVerseRecommendations(translatedTranscript);
            resolvedScriptures.addAll(recommended);
          } catch (e) {
            print("Semantic verse recommendation fallback error: $e");
          }
        }

        // Prepare key scripture reference name
        if (resolvedScriptures.isNotEmpty) {
          final first = resolvedScriptures.first;
          keyScripture = '${first.koreanBookName} ${first.chapter}:${first.verse} / ${first.englishBookName} ${first.chapter}:${first.verse}';
          keyScriptureTextKor = first.koreanText;
          keyScriptureTextEng = first.englishText;
        }

        try {
          final reportLanguage = _isEnglishToKorean ? "Korean" : "English";
          final prompt = """
You are a professional sermon assistant. Generate a structured summary of the following sermon translation/transcript.
IMPORTANT: You MUST write the entire response content (including title, category, summary, application, prayer) in $reportLanguage.

Provide the response strictly as a JSON object with the following keys:
- "title": A concise main topic or title of the sermon.
- "category": A 1-word theme/category (e.g. FAITH, LOVE, GRACE, HOPE).
- "summary": A JSON array of 3 bullet points summarizing the sermon.
- "keyScripture": The key Bible passage reference (e.g. "John 3:16" or "요한복음 3:16").
- "application": A JSON array of 2-3 practical application points.
- "prayer": A JSON array of 2-3 prayer points.

Do not include any explanation or markdown formatting like ```json. Just return the raw JSON object.

Sermon Transcript:
$translatedTranscript
""";

          final response = await _geminiModel!.generateContent([Content.text(prompt)]);
          if (response.text != null && response.text!.trim().isNotEmpty) {
            String cleanJson = response.text!.trim();
            if (cleanJson.startsWith("```")) {
              final lines = cleanJson.split("\n");
              if (lines.first.startsWith("```")) {
                lines.removeAt(0);
              }
              if (lines.isNotEmpty && lines.last.startsWith("```")) {
                lines.removeLast();
              }
              cleanJson = lines.join("\n").trim();
            }

            try {
              final Map<String, dynamic> summaryJson = jsonDecode(cleanJson);
              title = summaryJson['title'] ?? title;
              category = (summaryJson['category'] ?? category).toUpperCase();
              summaryPoints = List<String>.from(summaryJson['summary'] ?? summaryPoints);
              
              // If Gemini returned a different key passage, try to resolve it
              final String geminiScripture = summaryJson['keyScripture'] ?? '';
              if (geminiScripture.isNotEmpty && _bibleLibrary != null) {
                final resolved = _bibleLibrary!.parseReferences(geminiScripture);
                if (resolved.isNotEmpty) {
                  final first = resolved.first;
                  keyScripture = '${first.koreanBookName} ${first.chapter}:${first.verse}';
                  keyScriptureTextKor = first.koreanText;
                  keyScriptureTextEng = first.englishText;
                } else {
                  keyScripture = geminiScripture;
                }
              }
              
              appPoints = List<String>.from(summaryJson['application'] ?? appPoints);
              prayerPoints = List<String>.from(summaryJson['prayer'] ?? prayerPoints);
            } catch (jsonErr) {
              print("Failed parsing Gemini JSON summary: $jsonErr");
            }
          }
        } catch (e) {
          print("Gemini structured summary error: $e. Using smart local fallback analyzer.");
          // SMART LOCAL FALLBACK ANALYZER
          final lowerText = translatedTranscript.toLowerCase();
          if (lowerText.contains("믿음") || lowerText.contains("시련") || lowerText.contains("고난") || lowerText.contains("faith") || lowerText.contains("trial")) {
            title = "믿음의 시련을 이기는 소망";
            category = "FAITH";
            summaryPoints = [
              '고난 속에서 낙심하지 않고 하나님의 더 크신 섭리를 바라봅니다.',
              '믿음의 시련은 우리의 인내를 온전케 하며 신앙의 성숙으로 이끕니다.',
              '삶의 거친 풍랑 속에서도 요동치 않고 믿음의 방패를 굳게 잡습니다.'
            ];
            appPoints = [
              '시련이 찾아올 때 불평하는 대신 먼저 기도로 무릎 꿇기.',
              '고난 속에서도 감사할 제목 3가지를 찾아서 매일 고백하기.'
            ];
            prayerPoints = [
              '환난 속에서도 흔들리지 않는 굳건하고 순전한 믿음을 부어 주옵소서.',
              '시련의 어두운 터널 속에서 오직 소망의 주님만을 신뢰하게 하소서.'
            ];
          } else if (lowerText.contains("사랑") || lowerText.contains("이웃") || lowerText.contains("형제") || lowerText.contains("love")) {
            title = "그리스도의 사랑으로 하나 됨";
            category = "LOVE";
            summaryPoints = [
              '하나님이 우리를 먼저 사랑하셨기에 우리도 마땅히 형제를 사랑해야 합니다.',
              '이웃을 내 몸과 같이 사랑하라는 말씀은 주님이 주신 가장 큰 계명입니다.',
              '말과 혀로만 사랑하지 않고 오직 행함과 진실함으로 실천합니다.'
            ];
            appPoints = [
              '이번 주간 주변의 소외된 이웃 한 명에게 구체적인 사랑과 나눔 실천하기.',
              '나에게 상처 준 사람을 그리스도의 사랑으로 용서하고 품기.'
            ];
            prayerPoints = [
              '예수 그리스도의 아낌없는 십자가 사랑을 닮아 온전히 사랑하는 자가 되게 하소서.',
              '내 안에 미움과 시기를 버리고 화평을 이루는 통로로 살아가게 하소서.'
            ];
          } else if (lowerText.contains("은혜") || lowerText.contains("십자가") || lowerText.contains("보혈") || lowerText.contains("grace")) {
            title = "십자가의 은혜와 구원의 소망";
            category = "GRACE";
            summaryPoints = [
              '우리는 아무 자격 없으나 오직 주님의 값없는 은혜로 구원받았습니다.',
              '예수 그리스도의 십자가 보혈로 우리의 모든 허물과 죄가 씻어졌습니다.',
              '은혜에 합당한 삶을 살기 위해 늘 감사와 감격 속에 머무릅니다.'
            ];
            appPoints = [
              '나를 구원하신 주님의 은혜를 매일 아침 5분씩 조용히 묵상하기.',
              '십자가의 사랑과 복음의 기쁜 소식을 주변 이웃에게 전하기.'
            ];
            prayerPoints = [
              '자격 없는 내게 풍성한 사랑을 베푸신 주님의 무한한 은혜에 감격하게 하소서.',
              '날마다 십자가를 묵상하며 죄에서 돌이켜 주께 한 걸음 더 나아가게 하소서.'
            ];
          } else {
            // Default smart fallback based on general sermon flow
            title = "말씀의 성취와 삶의 열매";
            category = "FAITH";
            summaryPoints = [
              '선포된 말씀이 내 마음의 좋은 밭에 떨어져 100배의 결실을 맺기를 소망합니다.',
              '세상의 걱정과 유혹 속에서도 믿음의 뿌리를 말씀 위에 굳게 내립니다.',
              '예배를 마친 후 들은 말씀을 삶의 자리에서 온전한 행함으로 살아냅니다.'
            ];
            appPoints = [
              '오늘 주신 말씀 중 마음에 와닿은 구절 하나를 하루 동안 읊조리기.',
              '말씀 묵상과 기도로 매일의 삶을 결단하며 살아가기.'
            ];
            prayerPoints = [
              '말씀을 듣고 잊어버리는 자가 아니라 삶으로 행하는 지혜로운 신앙인이 되게 하소서.',
              '세상의 어두운 그늘 속에서 말씀의 빛과 소금의 역할을 감당하게 하소서.'
            ];
          }
        }
      } 
      // 2. SIMULATION/DEMO MODE ACTIVE
      else {
        // Resolve default references (Psalm 23:1) for demonstration
        if (_bibleLibrary != null) {
          final first = _bibleLibrary!.lookupReference("시편", 23, 1);
          if (first != null) {
            resolvedScriptures.add(first);
            keyScripture = '${first.koreanBookName} ${first.chapter}:${first.verse} / ${first.englishBookName} ${first.chapter}:${first.verse}';
            keyScriptureTextKor = first.koreanText;
            keyScriptureTextEng = first.englishText;
          }
        }
        
        title = '선한 목자의 인도하심 (The Good Shepherd)';
        category = 'FAITH';
        summaryPoints = [
          '여호와께서 우리의 목자가 되심으로써 우리는 어떠한 부족함도 느끼지 않습니다.',
          '인생의 사망의 음침한 골짜기를 지나갈 때에도 주께서 늘 동행하시기에 요동치 않습니다.',
          '주의 지팡이와 막대기가 보호하시며 원수 앞에서도 상을 넘치도록 베풀어 주십니다.'
        ];
        appPoints = [
          '목자 되신 하나님을 전적으로 신뢰하며 매일의 불안을 주께 내어 맡깁니다.',
          '가장 어려운 시기에도 평강을 주시는 성령의 보호하심을 의지합니다.'
        ];
        prayerPoints = [
          '선한 목자의 음성만을 온전히 따르는 순종의 자녀가 되게 하소서.',
          '사망의 골짜기 앞에서도 오직 주의 도우심만을 바라보게 하소서.'
        ];
      }

      _todaySermonTitle = title;
      _todaySermonCategory = category;
      _todaySermonKeyScripture = keyScripture;
      _todaySermonKeyScriptureTextKor = keyScriptureTextKor;
      _todaySermonKeyScriptureTextEng = keyScriptureTextEng;
      _todaySermonBulletPoints = summaryPoints;
      _todaySermonApplicationPoints = appPoints;
      _todaySermonPrayerPoints = prayerPoints;

      // Construct markdown string for home screen backward compatibility
      _todaySermonSummary = _formatSummaryMarkdown(
        title,
        keyScripture,
        keyScriptureTextKor,
        keyScriptureTextEng,
        summaryPoints,
        appPoints,
        prayerPoints,
      );
      notifyListeners();

      try {
        final docRef = await _firestore.collection('summaries').add({
          'title': title,
          'date': DateTime.now().toString().substring(0, 10),
          'category': category,
          'bulletPoints': summaryPoints,
          'keyScripture': keyScripture.isNotEmpty ? keyScripture : '실시간 음성 인식 세션',
          'keyScriptureTextKor': keyScriptureTextKor,
          'keyScriptureTextEng': keyScriptureTextEng,
          'applicationPoints': appPoints,
          'prayerPoints': prayerPoints,
          'takeaway': appPoints.isNotEmpty ? appPoints.first : '방금 인식된 설교 음성을 홈 화면에 바로 요약했습니다.',
          'audioUrl': 'assets/sample_sermon.mp3',
          'rawTranscript': rawTranscript,
          'translatedTranscript': translatedTranscript,
          'userId': _user?.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'userComment': '',
        });
        _todaySummaryDocId = docRef.id;
        _todaySermonUserComment = "";
        notifyListeners();
      } catch (e) {
        print("Firestore summary save error: $e");
      }
    }

    notifyListeners();
  }

  Future<void> deleteSummary(String summaryId) async {
    try {
      await _firestore.collection('summaries').doc(summaryId).delete();
    } catch (e) {
      print("Error deleting summary: $e");
    }
  }

  Future<void> updateSummary({
    required String id,
    required List<String> bulletPoints,
    required List<String> applicationPoints,
    required List<String> prayerPoints,
    String? userComment,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'bulletPoints': bulletPoints,
        'applicationPoints': applicationPoints,
        'prayerPoints': prayerPoints,
      };
      if (userComment != null) {
        updates['userComment'] = userComment;
      }

      await _firestore.collection('summaries').doc(id).update(updates);

      // If this is today's summary, update the local variables too
      if (id == _todaySummaryDocId) {
        _todaySermonBulletPoints = bulletPoints;
        _todaySermonApplicationPoints = applicationPoints;
        _todaySermonPrayerPoints = prayerPoints;
        if (userComment != null) {
          _todaySermonUserComment = userComment;
        }

        // Rebuild todaySermonSummary markdown
        _todaySermonSummary = _formatSummaryMarkdown(
          _todaySermonTitle.isNotEmpty ? _todaySermonTitle : '오늘의 실시간 STT 설교 요약',
          _todaySermonKeyScripture,
          _todaySermonKeyScriptureTextKor,
          _todaySermonKeyScriptureTextEng,
          bulletPoints,
          applicationPoints,
          prayerPoints,
        );
      }
      notifyListeners();
    } catch (e) {
      print("Error updating summary in provider: $e");
    }
  }

  bool _showTutorial = false;
  bool get showTutorial => _showTutorial;
  int _tutorialStep = 0;
  int get tutorialStep => _tutorialStep;

  void triggerTutorial() {
    _showTutorial = true;
    _tutorialStep = 0;
    notifyListeners();
  }

  void completeTutorial() {
    _showTutorial = false;
    _tutorialStep = 0;
    updateUserPreference(hasSeenTutorial: true);
    notifyListeners();
  }

  void nextTutorialStep() {
    _tutorialStep++;
    notifyListeners();
  }

  void previousTutorialStep() {
    if (_tutorialStep > 0) {
      _tutorialStep--;
      notifyListeners();
    }
  }

  void setTutorialStep(int step) {
    _tutorialStep = step;
    notifyListeners();
  }

  String _formatSummaryMarkdown(
    String title,
    String keyScripture,
    String keyScriptureTextKor,
    String keyScriptureTextEng,
    List<String> summaryPoints,
    List<String> appPoints,
    List<String> prayerPoints,
  ) {
    final buffer = StringBuffer();
    buffer.writeln("### ⛪ 핵심 주제: $title");
    buffer.writeln();
    if (keyScripture.isNotEmpty) {
      buffer.writeln("📖 **관련 성경 본문:** $keyScripture");
      if (keyScriptureTextKor.isNotEmpty) {
        buffer.writeln("> $keyScriptureTextKor");
      }
      if (keyScriptureTextEng.isNotEmpty) {
        buffer.writeln("> *${keyScriptureTextEng}*");
      }
      buffer.writeln();
    }
    buffer.writeln("💡 **설교 요약:**");
    for (final pt in summaryPoints) {
      buffer.writeln("- $pt");
    }
    buffer.writeln();
    if (appPoints.isNotEmpty) {
      buffer.writeln("🏃 **적용점:**");
      for (final pt in appPoints) {
        buffer.writeln("- $pt");
      }
      buffer.writeln();
    }
    if (prayerPoints.isNotEmpty) {
      buffer.writeln("🙏 **기도 제목:**");
      for (final pt in prayerPoints) {
        buffer.writeln("- $pt");
      }
    }
    return buffer.toString();
  }

  // 3. Summaries Collection Sync & Default Inserter
  void _listenToSummaries() {
    _firestore
        .collection('summaries')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) {
            // If empty, initialize default database entries for user presentation
            _initializeDefaultSummaries();
          } else {
            _summaries = snapshot.docs
                .map((doc) => SermonSummary.fromFirestore(doc))
                .toList();
            notifyListeners();
          }
        });
  }

  Future<void> _initializeDefaultSummaries() async {
    final defaultData = [
      {
        'title': 'The Architecture of Hope',
        'date': 'OCT 22, 2023',
        'category': 'FAITH',
        'bulletPoints': [
          'The sermon explores how hope serves as a structural foundation for endurance. Rather than a fleeting feeling, hope is described as an active choice to trust in divine timing.',
          'Key scripture: Romans 15:13. The focus was on "overflowing with hope by the power of the Holy Spirit," suggesting that our internal capacity is expanded during trials.',
          'Closing takeaway: Hope requires community. We are encouraged to build supportive networks that remind us of the promises when we feel the structure weakening.',
        ],
        'keyScripture': 'Romans 15:13',
        'takeaway':
            'Hope requires community. We are encouraged to build supportive networks that remind us of the promises when we feel the structure weakening.',
        'audioUrl': 'assets/sample_sermon.mp3',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 30)),
        ),
      },
      {
        'title': 'Living in Tension',
        'date': 'OCT 15, 2023',
        'category': 'THEOLOGY',
        'bulletPoints': [
          'Life in the middle grounds requires an active trust. We are placed between the already-achieved and the not-yet-fulfilled.',
          'Understanding tension as a room for character development and spiritual maturity.',
          'We should embrace questions rather than forcing immediate binary answers.',
        ],
        'keyScripture': 'James 1:2-4',
        'takeaway':
            'Embrace the tension as the very catalyst that shapes robust, unwavering faith.',
        'audioUrl': 'assets/sample_sermon.mp3',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 37)),
        ),
      },
      {
        'title': 'The Sound of Silence',
        'date': 'SEP 28, 2023',
        'category': 'WISDOM',
        'bulletPoints': [
          'Silence is not the absence of God, but a place for deeper intimacy.',
          'Learning to hear the gentle whisper of God over the loud voices of modern busyness.',
          'Practicing daily solitude as a necessity for spiritual realignment.',
        ],
        'keyScripture': '1 Kings 19:11-13',
        'takeaway': 'In quietness and confidence shall be your strength.',
        'audioUrl': 'assets/sample_sermon.mp3',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 54)),
        ),
      },
      {
        'title': 'Redefining Success',
        'date': 'SEP 21, 2023',
        'category': 'PURPOSE',
        'bulletPoints': [
          'Success in the Kingdom is measured by faithfulness, not cultural popularity or metric achievements.',
          'Aligning our daily priorities with eternal value rather than temporary validation.',
          'Joy is found in the ordinary service of love to those around us.',
        ],
        'keyScripture': 'Matthew 25:21',
        'takeaway':
            'Well done, good and faithful servant. Enter into the joy of your Lord.',
        'audioUrl': 'assets/sample_sermon.mp3',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 61)),
        ),
      },
    ];

    WriteBatch batch = _firestore.batch();
    for (var data in defaultData) {
      DocumentReference ref = _firestore.collection('summaries').doc();
      batch.set(ref, data);
    }
    await batch.commit();
  }

  // 4. Archive Collection & User Saved Sync
  void _listenToArchiveItems() {
    _firestore.collection('archives').snapshots().listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        _initializeDefaultArchive();
      } else {
        _archiveItems = snapshot.docs
            .map((doc) => SavedItem.fromFirestore(doc))
            .toList();
        notifyListeners();
      }
    });
  }

  void _listenToSavedUserItems() {
    if (_user == null) return;
    _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('saved_items')
        .snapshots()
        .listen((snapshot) {
          _savedItemIds = snapshot.docs.map((doc) => doc.id).toSet();
          notifyListeners();
        });
  }

  Future<void> _initializeDefaultArchive() async {
    final defaultData = [
      {
        'type': 'verse',
        'serviceType': 'SUNDAY SERVICE',
        'date': 'Oct 27, 2024',
        'title': 'VERSE OF THE DAY: John 3:16',
        'content':
            '"For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life."',
        'authorOrVersion': 'NIV Version',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 200)),
        ),
      },
      {
        'type': 'verse',
        'serviceType': 'MIDWEEK SERVICE',
        'date': 'Oct 23, 2024',
        'title': 'VERSE OF THE DAY: Psalm 23:1',
        'content': '"The Lord is my shepherd; I shall not want. He makes me lie down in green pastures. He leads me beside still waters."',
        'authorOrVersion': 'ESV Version',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 204)),
        ),
      },
      {
        'type': 'verse',
        'serviceType': 'FRIDAY PRAYER',
        'date': 'Nov 8, 2024',
        'title': 'VERSE OF THE DAY: Philippians 4:13',
        'content': '"I can do all this through him who gives me strength."',
        'authorOrVersion': 'NIV Version',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 188)),
        ),
      },
      {
        'type': 'verse',
        'serviceType': 'SUNDAY SERVICE',
        'date': 'Nov 17, 2024',
        'title': 'VERSE OF THE DAY: Jeremiah 29:11',
        'content': '"For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, plans to give you hope and a future."',
        'authorOrVersion': 'NIV Version',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 179)),
        ),
      },
      {
        'type': 'quote',
        'serviceType': 'SUNDAY SERVICE',
        'date': 'Oct 27, 2024',
        'title': 'Key Sermon Quote',
        'content':
            '"Faith is not the absence of doubt, but the courage to trust God in the midst of it."',
        'authorOrVersion': 'Pastor David Miller',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 200)),
        ),
      },
      {
        'type': 'quote',
        'serviceType': 'FRIDAY PRAYER',
        'date': 'Nov 8, 2024',
        'title': 'Key Sermon Quote',
        'content':
            '"Prayer is not asking. It is a longing of the soul. It is daily admission of one\'s weakness. It is better in prayer to have a heart without words than words without a heart."',
        'authorOrVersion': 'Pastor Sarah Kim',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 188)),
        ),
      },
    ];

    WriteBatch batch = _firestore.batch();
    for (var data in defaultData) {
      DocumentReference ref = _firestore.collection('archives').doc();
      batch.set(ref, data);
    }
    await batch.commit();
  }

  // Toggle Save Item to user's saved list
  Future<void> toggleSaveItem(String itemId) async {
    if (_user == null) return;
    try {
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('saved_items')
          .doc(itemId);

      if (_savedItemIds.contains(itemId)) {
        await docRef.delete();
        _savedItemIds.remove(itemId);
      } else {
        await docRef.set({'savedAt': FieldValue.serverTimestamp()});
        _savedItemIds.add(itemId);
      }
      notifyListeners();
    } catch (e) {
      print("Error toggling save item: $e");
    }
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[now.month - 1]} ${now.day}, ${now.year}";
  }

  Future<void> saveBibleVerse({
    required String title,
    required String content,
    required String version,
  }) async {
    if (_user == null) return;
    try {
      // 1. Check if same content exists in archives
      QuerySnapshot query = await _firestore
          .collection('archives')
          .where('content', isEqualTo: content)
          .where('type', isEqualTo: 'verse')
          .limit(1)
          .get();

      String itemId;
      if (query.docs.isNotEmpty) {
        itemId = query.docs.first.id;
      } else {
        final formattedDate = _formatCurrentDate();
        DocumentReference newDoc = await _firestore.collection('archives').add({
          'type': 'verse',
          'serviceType': 'BIBLE STUDY',
          'date': formattedDate,
          'title': title,
          'content': content,
          'authorOrVersion': version,
          'timestamp': FieldValue.serverTimestamp(),
        });
        itemId = newDoc.id;
      }

      // 2. Add to user's saved_items
      DocumentReference userSaveRef = _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('saved_items')
          .doc(itemId);

      await userSaveRef.set({'savedAt': FieldValue.serverTimestamp()});
      if (!_savedItemIds.contains(itemId)) {
        _savedItemIds.add(itemId);
      }
      notifyListeners();
    } catch (e) {
      print("Error saving bible verse: $e");
    }
  }

  // Simple authentication helpers
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      print("signUp: Creating user with email $email");
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("signUp: Auth successful, writing to Firestore");
      if (credential.user != null) {
        bool isGuest = name.toLowerCase().contains("guest");
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'displayName': isGuest ? "게스트 (Guest)" : name,
          'userRole': isGuest
              ? "게스트 성도 (Guest)"
              : "성도 (Member)",
          'translationLanguage': "English",
          'appearance': "System Default",
          'pushNotifications': true,
          'preferredBibleVersion': "NIV",
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'useRealAI': false, // defaults to false (Guide/Tutorial mode)
          'translationCount': 0,
          'hasSeenTutorial': false,
        });
        print("signUp: Firestore write successful");
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("signUp failed: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fastGuestSignIn() async {
    _isLoading = true;
    notifyListeners();
    final email = "fast_guest@sermon.com";
    final password = "guest12345";
    try {
      print("fastGuestSignIn: Trying signInWithEmailAndPassword");
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("fastGuestSignIn: signIn success!");
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("fastGuestSignIn: signIn failed with $e, attempting signUp");
      return await signUp(email, password, "게스트 (Guest)");
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      print("Error sending password reset email: $e");
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Skip native Google Sign-In on iOS (debug mode) to avoid 404/invalid_client
      if (Platform.isIOS && !kReleaseMode) {
        // Simulate bypass
        throw Exception('Simulator - bypass native sign-in');
      }
      // 1. Try actual native Google Sign-In with explicitly provided Client IDs
      // to resolve 401: invalid_client errors on iOS.
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // iOS Client ID from GoogleService-Info.plist
        clientId: Platform.isIOS ? '241632718216-71ed0f3ee6c09a3e635e3d.apps.googleusercontent.com' : null,
        // Web Client ID from Firebase Console (for idToken generation)
        serverClientId: '241632718216-bfu5819ksmb0g8de1jk6k9n6cd87bt1i.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      _user = userCredential.user;
      if (_user != null) {
        // Ensure user document exists with Premium tier
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(_user!.uid)
            .get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(_user!.uid).set({
            'displayName': _user!.displayName ?? "사용자 (User)",
            'userRole': "성도 (Member)",
            'translationLanguage': "English",
            'appearance': "System Default",
            'pushNotifications': true,
            'preferredBibleVersion': "NIV",
            'email': _user!.email,
            'createdAt': FieldValue.serverTimestamp(),
            'useRealAI': true, // Auto-enable real AI for members
            'translationCount': 0,
            'hasSeenTutorial': false,
          });
        }
        await _loadUserProfile();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Google Sign-In Failed, running presenter fallback: $e");

      // 2. Safe Presenter Fallback: Create/Sign-in to a robust premium demo user in Firebase Auth!
      // This guarantees the demo will never fail due to simulator native sign-in issues.
      try {
        final email = "premium_demo@sermon.com";
        final password = "premium12345";

        UserCredential credential;
        try {
          credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (_) {
          // If demo account doesn't exist, sign up
          credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        }

        _user = credential.user;
        if (_user != null) {
          await _firestore.collection('users').doc(_user!.uid).set({
            'displayName': "데모 성도 (Demo User)",
            'userRole': "성도 (Member)",
            'translationLanguage': "English",
            'appearance': "System Default",
            'pushNotifications': true,
            'preferredBibleVersion': "NIV",
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'useRealAI': true,
            'translationCount': 0,
            'hasSeenTutorial': false,
          });
          await _loadUserProfile();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (innerError) {
        print("Fallback Auth Error: $innerError");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }
  }

  Future<void> incrementTranslationCount() async {
    if (_user == null) return;
    if (_userRole.contains("👑")) return; // Premium members have no limits!

    _translationCount++;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'translationCount': _translationCount,
      });
    } catch (e) {
      print("Error updating translation count: $e");
    }
  }

  Future<String> askGeminiAboutSermon(
    String sermonTitle,
    String sermonSummaryPoints,
    String question,
  ) async {
    // Injected user's actual API key directly for seamless operation!
    final geminiApiKey = _customGeminiApiKey.trim().isNotEmpty
        ? _customGeminiApiKey.trim()
        : const String.fromEnvironment(
            'GEMINI_API_KEY',
            defaultValue: 'AIzaSyBKB3_goai6MVnA5uQ89_BJyg9jCAVo1Uk',
          );

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: geminiApiKey,
    );

    final prompt =
        """
우리는 기독교 예배 설교 자막/요약 관리 서비스인 'HISpeak'입니다.
다음은 사용자가 들은 설교 요약 정보입니다:
제목: $sermonTitle
요약 내용: $sermonSummaryPoints

이 설교 내용 및 성경 전체의 복음적인 관점에서 사용자의 질문에 답해 주세요.
친절하고 깊이 있는 신학적 해설을 제공하며, 어조는 은혜롭고 정갈한 한국어로 경어체를 사용해 주십시오.

사용자의 질문: "$question"
""";

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "죄송합니다. 답변을 생성할 수 없습니다. 다시 시도해 주세요.";
    } catch (e) {
      print("Gemini QA Error: $e");
      return "네트워크 오류가 발생했습니다. AI 연결 상태를 확인한 후 다시 질문해 주세요. ($e)";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _stopLiveTranslation();
    super.dispose();
  }
}
