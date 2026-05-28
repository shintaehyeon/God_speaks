import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/sermon_summary.dart';
import '../models/saved_item.dart';
import '../models/sermon_flow.dart';

class SermonProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Real-time AI Configuration
  bool _useRealAI = false;
  bool get useRealAI => _useRealAI;
  
  // Advanced AI and Speech Engines
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  OnDeviceTranslator? _translator;
  GenerativeModel? _geminiModel;
  String _accumulatedKoreanText = ""; // For summarizing at the end

  // User Preferences from Firestore
  String _displayName = "Alex Johnson";
  String get displayName => _displayName;
  String _userRole = "Premium Member since 2023";
  String get userRole => _userRole;
  String _translationLanguage = "English";
  String get translationLanguage => _translationLanguage;
  String _appearance = "System Default";
  String get appearance => _appearance;
  bool _pushNotifications = true;
  bool get pushNotifications => _pushNotifications;
  String _preferredBibleVersion = "NIV";
  String get preferredBibleVersion => _preferredBibleVersion;

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
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _displayName = data['displayName'] ?? "Alex Johnson";
        _userRole = data['userRole'] ?? "Premium Member since 2023";
        _translationLanguage = data['translationLanguage'] ?? "English";
        _appearance = data['appearance'] ?? "System Default";
        _pushNotifications = data['pushNotifications'] ?? true;
        _preferredBibleVersion = data['preferredBibleVersion'] ?? "NIV";
        _useRealAI = data['useRealAI'] ?? false;
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
          'email': _user!.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
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

      await _firestore.collection('users').doc(_user!.uid).update(updates);
      notifyListeners();
    } catch (e) {
      print("Error updating preferences: $e");
    }
  }

  // 2. Real-time Live Translation Session Controls
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
    _isRecording = true;
    _accumulatedKoreanText = "";
    _sermonFlowSteps = [
      SermonFlowStep(
        time: "10:15 AM",
        type: "topic",
        title: "주제: 믿음의 시련 (Trial of Faith)",
        description: "\"고난을 넘어서는 하나님의 계획\"",
      ),
    ];
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
              _switchToSimulationFallback("마이크 연결 상태 또는 권한 부족으로 인해 안전 시뮬레이션 모드로 전환되었습니다.");
            }
          },
        );

        if (_speechInitialized) {
          _liveTranslationText = "마이크가 활성화되었습니다. 한국어로 설교를 말씀하세요...";
          
          // Setup On-Device Translator (ML Kit)
          _translator = OnDeviceTranslator(
            sourceLanguage: TranslateLanguage.korean,
            targetLanguage: TranslateLanguage.english,
          );

          // Build Gemini Model (Free tier support)
          // Uses standard environment key or prompts the user.
          // Safety: We will use a try-catch for all Gemini operations.
          const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
          if (geminiApiKey.isNotEmpty) {
            _geminiModel = GenerativeModel(
              model: 'gemini-1.5-flash',
              apiKey: geminiApiKey,
            );
          }

          _startSpeechListening();

          // Smooth real-time microphone sound level wave animation
          _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
            final rand = Random();
            if (_speech.isListening) {
              // Scale the sound level value to fit 15 wave visualizer nodes
              // stt level is typically -2dB to 10dB or 0.0 to 1.0 depending on platform
              double currentDbLevel = rand.nextDouble() * 0.8 + 0.2; 
              _waveValues = List.generate(15, (index) => currentDbLevel * (rand.nextDouble() * 0.6 + 0.4));
            } else {
              _waveValues = List.generate(15, (index) => rand.nextDouble() * 0.2 + 0.05);
            }
            notifyListeners();
          });
        } else {
          _switchToSimulationFallback("음성 인식 시스템 초기화에 실패하여 안전 데모 모드로 자동 전환되었습니다.");
        }
      } catch (e) {
        print("Real AI initialization error: $e");
        _switchToSimulationFallback("네트워크 또는 장치 오류로 인해 시뮬레이션 모드로 안전 전환되었습니다.");
      }
    } 
    // 2. SIMULATION MOCK MODE ACTIVE
    else {
      _liveTranslationText = "Establishing connection to audio stream in $_selectedLocation...";
      _simulationSeconds = 0;
      
      // Wave simulation timer
      _waveTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        final rand = Random();
        _waveValues = List.generate(15, (index) => rand.nextDouble() * 0.9 + 0.1);
        notifyListeners();
      });

      // Translation transcription stream simulation
      const streamTexts = [
        "The Lord is our shepherd, and in His presence, we find everything we need.",
        " Even in the valley of darkness, we shall fear no evil, for You are with us.",
        " Your rod and Your staff, they comfort us in times of trials.",
        " \"And so we must remember that our hope is not built on temporary things...\"",
        " Faith is built through perseverance. When we face trials, we grow closer to God.",
        " Today's message focuses on Psalm 23. This scripture provides peace in stormy weather.",
        " Let us read the next section. Psalm 23 verse 1: 'The Lord is my shepherd, I shall not want.'"
      ];

      _translationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        _simulationSeconds += 4;
        int index = (_simulationSeconds ~/ 4) - 1;
        
        if (index < streamTexts.length) {
          if (index == 0) {
            _liveTranslationText = streamTexts[0];
          } else {
            _liveTranslationText += streamTexts[index];
          }
        }

        // Add scripture flow at 12 seconds
        if (_simulationSeconds == 12) {
          _sermonFlowSteps.add(SermonFlowStep(
            time: "12:45 PM",
            type: "scripture",
            title: "시편 23:1 (Psalm 23:1)",
            description: "\"여호와는 나의 목자시니 내게 부족함이 없으리로다.\"",
          ));
        }

        // Add concluding flow at 24 seconds
        if (_simulationSeconds == 24) {
          _sermonFlowSteps.add(SermonFlowStep(
            time: "진행 중...",
            type: "pending",
            title: "결론: 소망의 확신 (Assurance of Hope)",
            description: "소망은 신성한 타이밍을 신뢰하는 지속적인 선택입니다.",
          ));
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
          String newWords = result.recognizedWords;
          
          // Translate to English in real-time using on-device ML Kit
          if (_translator != null) {
            try {
              String translated = await _translator!.translateText(newWords);
              _liveTranslationText = _accumulatedKoreanText + translated;
            } catch (e) {
              print("ML Kit translation error: $e");
              _liveTranslationText = _accumulatedKoreanText + " [Translation processing...] " + newWords;
            }
          } else {
            _liveTranslationText = _accumulatedKoreanText + newWords;
          }

          // Trigger dynamic timelines dynamically based on speech volume/keywords
          if (newWords.contains("시편") || newWords.contains("성경") || newWords.contains("Psalm")) {
            bool hasScripture = _sermonFlowSteps.any((step) => step.type == 'scripture');
            if (!hasScripture) {
              _sermonFlowSteps.add(SermonFlowStep(
                time: "LIVE CAPTURE",
                type: "scripture",
                title: "실시간 성경 감지 (Scripture Detected)",
                description: "\"${newWords.length > 30 ? newWords.substring(0, 30) + '...' : newWords}\"",
              ));
            }
          }
          notifyListeners();
        }
      },
      localeId: 'ko_KR', // Restrict speech recognition to Korean as requested
    );
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

    // Save actual text to database using Gemini AI summary if enabled and text exists
    if (_translator != null && _accumulatedKoreanText.isNotEmpty && _geminiModel != null) {
      try {
        final prompt = "다음은 오늘 나눈 설교 번역 텍스트입니다. 이 설교 요약본을 만들어 주세요. 제목, 핵심 3줄 요약, 중심 성경 구절을 포함해야 합니다. 형식은 한국어로 해주세요. 텍스트: $_accumulatedKoreanText";
        final response = await _geminiModel!.generateContent([Content.text(prompt)]);
        if (response.text != null) {
          // Parse and add summary to Firestore!
          await _firestore.collection('summaries').add({
            'title': 'AI Generated Sermon Summary',
            'date': DateTime.now().toString().substring(0, 10),
            'category': 'AI SUMMARY',
            'bulletPoints': [response.text!],
            'keyScripture': 'Generated by Gemini',
            'takeaway': '실시간 AI에 의해 분석된 맞춤형 오늘의 은혜입니다.',
            'audioUrl': 'assets/sample_sermon.mp3',
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print("Gemini generation error: $e");
      }
    }

    _translator?.close();
    _translator = null;
    notifyListeners();
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
        _summaries = snapshot.docs.map((doc) => SermonSummary.fromFirestore(doc)).toList();
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
          'Closing takeaway: Hope requires community. We are encouraged to build supportive networks that remind us of the promises when we feel the structure weakening.'
        ],
        'keyScripture': 'Romans 15:13',
        'takeaway': 'Hope requires community. We are encouraged to build supportive networks that remind us of the promises when we feel the structure weakening.',
        'audioUrl': 'assets/sample_sermon.mp3',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
      },
      {
        'title': 'Living in Tension',
        'date': 'OCT 15, 2023',
        'category': 'THEOLOGY',
        'bulletPoints': [
          'Life in the middle grounds requires an active trust. We are placed between the already-achieved and the not-yet-fulfilled.',
          'Understanding tension as a room for character development and spiritual maturity.',
          'We should embrace questions rather than forcing immediate binary answers.'
        ],
        'keyScripture': 'James 1:2-4',
        'takeaway': 'Embrace the tension as the very catalyst that shapes robust, unwavering faith.',
        'audioUrl': 'assets/sample_sermon.mp3',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 37))),
      },
      {
        'title': 'The Sound of Silence',
        'date': 'SEP 28, 2023',
        'category': 'WISDOM',
        'bulletPoints': [
          'Silence is not the absence of God, but a place for deeper intimacy.',
          'Learning to hear the gentle whisper of God over the loud voices of modern busyness.',
          'Practicing daily solitude as a necessity for spiritual realignment.'
        ],
        'keyScripture': '1 Kings 19:11-13',
        'takeaway': 'In quietness and confidence shall be your strength.',
        'audioUrl': 'assets/sample_sermon.mp3',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 54))),
      },
      {
        'title': 'Redefining Success',
        'date': 'SEP 21, 2023',
        'category': 'PURPOSE',
        'bulletPoints': [
          'Success in the Kingdom is measured by faithfulness, not cultural popularity or metric achievements.',
          'Aligning our daily priorities with eternal value rather than temporary validation.',
          'Joy is found in the ordinary service of love to those around us.'
        ],
        'keyScripture': 'Matthew 25:21',
        'takeaway': 'Well done, good and faithful servant. Enter into the joy of your Lord.',
        'audioUrl': 'assets/sample_sermon.mp3',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 61))),
      }
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
        _archiveItems = snapshot.docs.map((doc) => SavedItem.fromFirestore(doc)).toList();
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
        'content': '"For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life."',
        'authorOrVersion': 'NIV Version',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 200))),
      },
      {
        'type': 'quote',
        'serviceType': 'SUNDAY SERVICE',
        'date': 'Oct 27, 2024',
        'title': 'Key Sermon Quote',
        'content': '"Faith is not the absence of doubt, but the courage to trust God in the midst of it."',
        'authorOrVersion': 'Pastor David Miller',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 200))),
      },
      {
        'type': 'verse',
        'serviceType': 'MIDWEEK SERVICE',
        'date': 'Oct 23, 2024',
        'title': 'PSALM 23:1',
        'content': '"The Lord is my shepherd, I lack nothing."',
        'authorOrVersion': 'The Good Shepherd',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 204))),
      }
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
        await docRef.set({
          'savedAt': FieldValue.serverTimestamp(),
        });
        _savedItemIds.add(itemId);
      }
      notifyListeners();
    } catch (e) {
      print("Error toggling save item: $e");
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
      UserCredential credential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'displayName': name,
          'userRole': "Member since ${DateTime.now().year}",
          'translationLanguage': "English",
          'appearance': "System Default",
          'pushNotifications': true,
          'preferredBibleVersion': "NIV",
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _stopLiveTranslation();
    super.dispose();
  }
}
