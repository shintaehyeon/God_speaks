import 'package:cloud_firestore/cloud_firestore.dart';

class Church {
  final String id;
  final String name;
  final String denomination;
  final List<String> languages;
  final List<String> worshipTimes;
  final String address;
  final String city;
  final String country;
  final String note;
  final String submittedBy;
  final String status;
  final DateTime createdAt;

  const Church({
    required this.id,
    required this.name,
    required this.denomination,
    required this.languages,
    required this.worshipTimes,
    required this.address,
    required this.city,
    required this.country,
    required this.note,
    required this.submittedBy,
    required this.status,
    required this.createdAt,
  });

  factory Church.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Church(
      id: doc.id,
      name: data['name'] ?? '',
      denomination: data['denomination'] ?? '',
      languages: List<String>.from(data['languages'] ?? []),
      worshipTimes: List<String>.from(data['worshipTimes'] ?? []),
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      note: data['note'] ?? '',
      submittedBy: data['submittedBy'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toSubmissionFirestore() {
    return {
      'name': name,
      'denomination': denomination,
      'languages': languages,
      'worshipTimes': worshipTimes,
      'address': address,
      'city': city,
      'country': country,
      'note': note,
      'submittedBy': submittedBy,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  String get languageLabel =>
      languages.isEmpty ? '언어 미등록' : languages.join(' / ');

  String get worshipLabel =>
      worshipTimes.isEmpty ? '예배 시간 미등록' : worshipTimes.join(' · ');

  String get regionLabel {
    final parts = [city, country].where((part) => part.trim().isNotEmpty);
    return parts.isEmpty ? '지역 미등록' : parts.join(', ');
  }

  static List<Church> sampleDirectory({String languageCode = 'ko'}) {
    final now = DateTime.now();
    final sampleOneName = switch (languageCode) {
      'ja' => '南フランス プロテスタント礼拝集会',
      'fr' => 'Culte protestant en Provence',
      _ => '남프랑스 개신교 예배 모임',
    };
    final sampleOneNote = switch (languageCode) {
      'ja' => '実際の教会情報が登録されると、確認後この一覧に公開されます。',
      'fr' =>
        'Les vraies informations d’église seront publiées ici après validation.',
      _ => '실제 교회 정보가 등록되면 검수 후 이 목록에 공개됩니다.',
    };
    final sampleTwoNote = switch (languageCode) {
      'ja' => '海外滞在者が礼拝言語と時間をすばやく確認するためのカード例です。',
      'fr' =>
        'Exemple de carte pour vérifier rapidement la langue et les horaires du culte à l’étranger.',
      _ => '해외 체류자가 예배 언어와 시간을 빠르게 확인하는 카드 예시입니다.',
    };
    final sampleAddress = switch (languageCode) {
      'ja' => '登録例の住所',
      'fr' => 'Adresse d’exemple',
      _ => '등록 예시 주소',
    };
    return [
      Church(
        id: 'sample-southern-france',
        name: sampleOneName,
        denomination: 'Protestant',
        languages: const ['Korean', 'English', 'French'],
        worshipTimes: const ['Sun 11:00'],
        address: sampleAddress,
        city: 'Southern France',
        country: 'France',
        note: sampleOneNote,
        submittedBy: '',
        status: 'sample',
        createdAt: now,
      ),
      Church(
        id: 'sample-international',
        name: 'International Worship Community',
        denomination: 'Evangelical / Protestant',
        languages: const ['English', 'French'],
        worshipTimes: const ['Sun 10:30', 'Wed 19:30'],
        address: sampleAddress,
        city: 'Europe',
        country: 'Global',
        note: sampleTwoNote,
        submittedBy: '',
        status: 'sample',
        createdAt: now,
      ),
    ];
  }
}
