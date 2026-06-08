import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenSourcePage extends StatelessWidget {
  const OpenSourcePage({Key? key}) : super(key: key);

  static const String _introHtml = '''
    <p><strong>Gods speak</strong>는 STT, 설교 요약 표시, 공유, 상태관리,
    로그인/Firebase 연동을 Flutter 오픈소스 패키지와 공식 SDK를 조합해 구현했습니다.</p>
    <p>아래 목록은 기말 프로젝트에서 실제 기능에 연결된 패키지입니다.</p>
  ''';

  static const List<_OpenSourcePackage> _packages = [
    _OpenSourcePackage(
      name: 'speech_to_text',
      role: '마이크 음성을 텍스트로 변환하는 STT Flutter 플러그인',
      license: 'BSD-3-Clause',
      status: '실시간 STT 핵심 기능',
      url: 'https://pub.dev/packages/speech_to_text',
    ),
    _OpenSourcePackage(
      name: 'flutter_markdown_plus',
      role: '오늘의 설교 요약과 지난 요약본을 Markdown 형식으로 렌더링',
      license: 'BSD-3-Clause',
      status: '요약 UI 렌더링',
      url: 'https://pub.dev/packages/flutter_markdown_plus',
    ),
    _OpenSourcePackage(
      name: 'flutter_widget_from_html_core',
      role: 'HTML 기반 설명 콘텐츠를 Flutter 위젯으로 렌더링',
      license: 'MIT',
      status: '오픈소스 내역 화면 설명 렌더링',
      url: 'https://pub.dev/packages/flutter_widget_from_html_core',
    ),
    _OpenSourcePackage(
      name: 'provider',
      role: '사용자 상태, STT 상태, 요약 데이터 상태관리',
      license: 'MIT',
      status: '앱 전역 상태관리',
      url: 'https://pub.dev/packages/provider',
    ),
    _OpenSourcePackage(
      name: 'share_plus',
      role: '설교 요약 리포트를 네이티브 공유 시트로 공유',
      license: 'BSD-3-Clause',
      status: '지난 요약본 공유',
      url: 'https://pub.dev/packages/share_plus',
    ),
    _OpenSourcePackage(
      name: 'url_launcher',
      role: '오픈소스 패키지 pub.dev 링크를 외부 브라우저로 열기',
      license: 'BSD-3-Clause',
      status: '라이선스 링크 열기',
      url: 'https://pub.dev/packages/url_launcher',
    ),
    _OpenSourcePackage(
      name: 'font_awesome_flutter',
      role: '구글 로그인 등 브랜드/보조 아이콘 표현',
      license: 'MIT',
      status: '로그인 UI',
      url: 'https://pub.dev/packages/font_awesome_flutter',
    ),
    _OpenSourcePackage(
      name: 'firebase_core',
      role: 'Firebase 초기화와 앱 연결',
      license: 'BSD-3-Clause',
      status: 'Firebase 기반 설정',
      url: 'https://pub.dev/packages/firebase_core',
    ),
    _OpenSourcePackage(
      name: 'firebase_auth',
      role: '게스트/구글 로그인 세션 관리',
      license: 'BSD-3-Clause',
      status: '로그인 인증',
      url: 'https://pub.dev/packages/firebase_auth',
    ),
    _OpenSourcePackage(
      name: 'cloud_firestore',
      role: 'STT 결과와 설교 요약을 Firestore에 저장',
      license: 'BSD-3-Clause',
      status: '요약 데이터 저장',
      url: 'https://pub.dev/packages/cloud_firestore',
    ),
    _OpenSourcePackage(
      name: 'firebase_app_check',
      role: 'Firebase 리소스 보호 설정 연동',
      license: 'BSD-3-Clause',
      status: '보안 설정',
      url: 'https://pub.dev/packages/firebase_app_check',
    ),
    _OpenSourcePackage(
      name: 'google_sign_in',
      role: '구글 계정 로그인 연동',
      license: 'BSD-3-Clause',
      status: '소셜 로그인',
      url: 'https://pub.dev/packages/google_sign_in',
    ),
    _OpenSourcePackage(
      name: 'google_generative_ai',
      role: 'Gemini API를 호출해 설교 요약과 번역 보조 생성',
      license: 'Apache-2.0',
      status: 'AI 요약 SDK',
      url: 'https://pub.dev/packages/google_generative_ai',
    ),
    _OpenSourcePackage(
      name: 'intl',
      role: '날짜/시간/지역화 형식 처리',
      license: 'BSD-3-Clause',
      status: '날짜 표시 보조',
      url: 'https://pub.dev/packages/intl',
    ),
    _OpenSourcePackage(
      name: 'lottie',
      role: '애니메이션 에셋 렌더링 지원',
      license: 'MIT',
      status: '시각 효과 지원',
      url: 'https://pub.dev/packages/lottie',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Open Source Libraries'),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.code_rounded,
                      color: Color(0xFF2F69F8),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '오픈소스 사용 내역',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                HtmlWidget(
                  _introHtml,
                  textStyle: TextStyle(
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    fontSize: 13,
                    height: 1.45,
                  ),
                  onTapUrl: (url) {
                    _openUrl(context, url);
                    return true;
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  '총 ${_packages.length}개 패키지 적용',
                  style: const TextStyle(
                    color: Color(0xFF2F69F8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._packages.map((package) {
            return _OpenSourcePackageTile(
              package: package,
              onOpen: () => _openUrl(context, package.url),
            );
          }),
        ],
      ),
    );
  }

  static Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final didOpen = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!didOpen && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('링크를 열 수 없습니다: $url')),
      );
    }
  }
}

class _OpenSourcePackageTile extends StatelessWidget {
  const _OpenSourcePackageTile({
    required this.package,
    required this.onOpen,
  });

  final _OpenSourcePackage package;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.extension_rounded,
              color: Color(0xFF2F69F8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  package.role,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _InfoPill(text: package.status),
                    _InfoPill(text: package.license),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'pub.dev 열기',
            onPressed: onOpen,
            icon: const Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2F69F8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OpenSourcePackage {
  const _OpenSourcePackage({
    required this.name,
    required this.role,
    required this.license,
    required this.status,
    required this.url,
  });

  final String name;
  final String role;
  final String license;
  final String status;
  final String url;
}
