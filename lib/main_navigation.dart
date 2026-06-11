import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'bible_page.dart';
import 'summaries.dart';
import 'archive.dart';
import 'settings.dart';
import 'theme.dart';
import 'state/sermon_provider.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const BiblePage(),
    const SummariesPage(),
    const ArchivePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sermonProvider = Provider.of<SermonProvider>(context);

    // Sync tab based on provider.tutorialStep
    if (sermonProvider.showTutorial) {
      int targetIndex = _currentIndex;
      if (sermonProvider.tutorialStep == 0 ||
          sermonProvider.tutorialStep == 1 ||
          sermonProvider.tutorialStep == 4) {
        targetIndex = 0;
      } else if (sermonProvider.tutorialStep == 5) {
        targetIndex = 1;
      } else if (sermonProvider.tutorialStep == 6) {
        targetIndex = 2;
      }
      if (_currentIndex != targetIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentIndex = targetIndex;
            });
          }
        });
      }
    }

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9),
                  width: 1.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              selectedItemColor: HISpeakTheme.purpleMain, // Active Purple
              unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), // Muted Gray-Blue
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_rounded),
                  ),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.menu_book_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.menu_book_rounded),
                  ),
                  label: '성경',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.article_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.article_rounded),
                  ),
                  label: '지난 요약본',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.bookmark_outline_rounded),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.bookmark_rounded),
                  ),
                  label: '보관된 구절',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.settings_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.settings_rounded),
                  ),
                  label: '설정',
                ),
              ],
            ),
          ),
        ),
        if (sermonProvider.showTutorial)
          _buildTutorialOverlay(context, sermonProvider),
      ],
    );
  }

  Widget _buildTutorialOverlay(BuildContext context, SermonProvider provider) {
    if (provider.tutorialStep == 2 || provider.tutorialStep == 3) {
      return const SizedBox();
    }

    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define coordinates and size based on the tutorial step
    Offset spotlightOffset = Offset.zero;
    double radius = 0;
    double width = 0;
    double height = 0;
    bool isCircle = true;
    bool noSpotlight = false;

    Widget tooltipContent = const SizedBox();
    double? tooltipTop;
    double? tooltipBottom;

    switch (provider.tutorialStep) {
      case 0:
        noSpotlight = true;
        tooltipTop = 0;
        tooltipBottom = 0;
        tooltipContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'HISpeak에 오신 것을 환영합니다! 🕊️',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFDDD6FE) : const Color(0xFF5B21B6),
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '안녕하세요! 앱 시작하기가 처음이시죠?\n예배의 말씀에 더 집중하실 수 있도록 주요 핵심 기능과 앱의 흐름을 빠르게 안내해 드릴게요!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                height: 1.6,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
        break;

      case 1:
        isCircle = true;
        spotlightOffset = Offset(size.width / 2, size.height * 0.49);
        radius = 115;
        tooltipTop = size.height * 0.11;
        tooltipContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.translate_rounded,
                  color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '1. 실시간 예배 번역 및 녹음',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFDDD6FE) : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '가운데 마이크 버튼을 터치하여 녹음을 시작해 보세요.\n목사님의 말씀이 실시간으로 기록되며, 즉시 영어 번역본이 화면에 실시간으로 생성됩니다.\n\n지금 \'다음\'을 누르면 가상 설교 번역 시뮬레이션이 시작됩니다!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
        break;

      case 4:
        isCircle = false;
        spotlightOffset = Offset(size.width / 2, size.height * 0.34);
        width = size.width - 24;
        height = 360;
        tooltipTop = size.height * 0.58;
        tooltipContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_done_rounded,
                  color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '4. 설교 종료 후 자동 저장 및 요약',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFDDD6FE) : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '설교가 종료되면 AI가 대본을 분석하여 핵심 요약, 관련 성경 구절, 삶의 적용점, 기도 제목을 자동으로 생성하여 보여줍니다.\n\n하단의 \'수정 / 코멘트 추가\' 버튼을 눌러 나만의 묵상 메모를 직접 작성할 수도 있습니다!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
        break;

      case 5:
        isCircle = true;
        spotlightOffset = Offset(size.width * 0.30, size.height - 45);
        radius = 45;
        tooltipBottom = 130;
        tooltipContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '5. 한영 대조 성경 읽기 & 보관',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFDDD6FE) : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '성경 탭에서는 개역개정과 영어 성경(ESV)을 대조해가며 은혜롭게 통독할 수 있습니다.\n\n은혜로운 구절을 길게 누르면 보관함으로 간편하게 스크랩해 둘 수 있습니다.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
        break;

      case 6:
        isCircle = true;
        spotlightOffset = Offset(size.width * 0.50, size.height - 45);
        radius = 45;
        tooltipBottom = 130;
        tooltipContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.archive_rounded,
                  color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '6. 설교 기록 아카이브',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFDDD6FE) : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '지난 요약본 탭에서는 지금까지 저장된 모든 설교 요약 기록을 한눈에 관리하고 언제든지 다시 열어볼 수 있습니다.\n\n이제 튜토리얼을 마치고 HISpeak의 모든 기능을 직접 경험해 보세요!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
        break;
    }

    return Positioned.fill(
      child: Stack(
        children: [
          // Purple-tinted Blurry Backdrop with Spotlight hole
          ClipPath(
            clipper: SpotlightClipper(
              spotlightOffset: spotlightOffset,
              radius: radius,
              width: width,
              height: height,
              isCircle: isCircle,
              noSpotlight: noSpotlight,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: isDark
                    ? const Color(0xFF0F0A1C).withOpacity(0.85) // Dark purple tint
                    : const Color(0xFF2E1A47).withOpacity(0.55), // Deep purple tint in light mode
              ),
            ),
          ),

          // Premium High-Contrast Card
          Positioned(
            top: tooltipTop,
            bottom: tooltipBottom,
            left: 20,
            right: 20,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1C122E), const Color(0xFF140B22)]
                        : [Colors.white, const Color(0xFFF5F3FF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color(0xFF8B5CF6).withOpacity(0.3)
                          : const Color(0xFF8B5CF6).withOpacity(0.15),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step Pill indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF8B5CF6).withOpacity(0.2) : const Color(0xFFF3F0FF),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isDark ? const Color(0xFFA78BFA) : const Color(0xFFC4B5FD),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '안내 ${provider.tutorialStep + 1} / 7',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFDDD6FE) : const Color(0xFF6D28D9),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        // Close / Skip Button (visible on all steps)
                        IconButton(
                          onPressed: () {
                            provider.completeTutorial();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            size: 20,
                          ),
                          tooltip: '튜토리얼 건너뛰기',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    tooltipContent,
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip / Back button
                        if (provider.tutorialStep > 0)
                          TextButton(
                            onPressed: () {
                              if (provider.tutorialStep == 4) {
                                // Go back to Step 3 on LiveTranslation screen
                                if (!provider.isRecording) {
                                  provider.toggleRecording();
                                }
                                Navigator.pushNamed(context, '/live');
                                provider.setTutorialStep(3);
                              } else if (provider.tutorialStep == 5) {
                                setState(() {
                                  _currentIndex = 0;
                                });
                                provider.previousTutorialStep();
                              } else if (provider.tutorialStep == 6) {
                                setState(() {
                                  _currentIndex = 1;
                                });
                                provider.previousTutorialStep();
                              } else {
                                provider.previousTutorialStep();
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text(
                              '이전',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: () {
                              provider.completeTutorial();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text(
                              '건너뛰기',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),

                        // Action / Next button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)]
                                  : [const Color(0xFF7C3AED), const Color(0xFF9061F9)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (provider.tutorialStep < 6) {
                                if (provider.tutorialStep == 1) {
                                  provider.nextTutorialStep();
                                  if (!provider.isRecording) {
                                    provider.toggleRecording();
                                  }
                                  Navigator.pushNamed(context, '/live');
                                } else if (provider.tutorialStep == 4) {
                                  setState(() {
                                    _currentIndex = 1;
                                  });
                                  provider.nextTutorialStep();
                                } else if (provider.tutorialStep == 5) {
                                  setState(() {
                                    _currentIndex = 2;
                                  });
                                  provider.nextTutorialStep();
                                } else {
                                  provider.nextTutorialStep();
                                }
                              } else {
                                provider.completeTutorial();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  provider.tutorialStep == 6 ? '시작하기 🎉' : '다음 기능',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                if (provider.tutorialStep < 6) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_rounded, size: 16),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpotlightClipper extends CustomClipper<Path> {
  final Offset spotlightOffset;
  final double radius;
  final double width;
  final double height;
  final bool isCircle;
  final bool noSpotlight;

  SpotlightClipper({
    required this.spotlightOffset,
    required this.radius,
    required this.width,
    required this.height,
    required this.isCircle,
    required this.noSpotlight,
  });

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (!noSpotlight) {
      if (isCircle) {
        path.addOval(Rect.fromCircle(center: spotlightOffset, radius: radius));
      } else {
        path.addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: spotlightOffset, width: width, height: height),
          const Radius.circular(16),
        ));
      }
    }

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant SpotlightClipper oldClipper) => true;
}
