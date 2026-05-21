import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      } else {
        // Create user document with defaults
        await _firestore.collection('users').doc(_user!.uid).set({
          'displayName': _displayName,
          'userRole': _userRole,
          'translationLanguage': _translationLanguage,
          'appearance': _appearance,
          'pushNotifications': _pushNotifications,
          'preferredBibleVersion': _preferredBibleVersion,
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

  void _startLiveTranslation() {
    _isRecording = true;
    _liveTranslationText = "Establishing connection to audio stream in $_selectedLocation...";
    _sermonFlowSteps = [
      SermonFlowStep(
        time: "10:15 AM",
        type: "topic",
        title: "주제: 믿음의 시련 (Trial of Faith)",
        description: "\"고난을 넘어서는 하나님의 계획\"",
      ),
    ];
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

    notifyListeners();
  }

  void _stopLiveTranslation() {
    _isRecording = false;
    _waveTimer?.cancel();
    _translationTimer?.cancel();
    _waveValues = List.filled(15, 0.1);
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
