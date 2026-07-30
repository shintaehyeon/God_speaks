import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'bible_page.dart';
import 'summaries.dart';
import 'church_finder.dart';
import 'community_page.dart';
import 'settings.dart';
import 'theme.dart';
import 'state/sermon_provider.dart';
import 'l10n/hispeak_localizations.dart';

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
    const ChurchFinderPage(),
    const CommunityPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sermonProvider = Provider.of<SermonProvider>(context);

    // Sync state index with provider index
    _currentIndex = sermonProvider.currentNavigationIndex;

    // Sync tab based on provider.tutorialStep
    if (sermonProvider.showTutorial) {
      int targetIndex = _currentIndex;
      if (sermonProvider.tutorialStep == 0 ||
          sermonProvider.tutorialStep == 1 ||
          sermonProvider.tutorialStep == 2 ||
          sermonProvider.tutorialStep == 3 ||
          sermonProvider.tutorialStep == 6) {
        targetIndex = 0;
      } else if (sermonProvider.tutorialStep == 7) {
        targetIndex = 1;
      } else if (sermonProvider.tutorialStep == 8) {
        targetIndex = 2;
      }
      if (_currentIndex != targetIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            sermonProvider.setNavigationIndex(targetIndex);
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
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFF1F5F9),
                  width: 1.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                sermonProvider.setNavigationIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              selectedItemColor: HISpeakTheme.purpleMain, // Active Purple
              unselectedItemColor: isDark
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8), // Muted Gray-Blue
              selectedLabelStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_outlined),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_rounded),
                  ),
                  label: context.l10n.t('home'),
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.menu_book_outlined),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.menu_book_rounded),
                  ),
                  label: context.l10n.t('bible'),
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.article_outlined),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.article_rounded),
                  ),
                  label: context.l10n.t('summaries'),
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.travel_explore_rounded),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.travel_explore_rounded),
                  ),
                  label: context.l10n.t('church'),
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.groups_2_outlined),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.groups_2_rounded),
                  ),
                  label: context.l10n.t('community'),
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.settings_outlined),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.settings_rounded),
                  ),
                  label: context.l10n.t('settings'),
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
    if (provider.tutorialStep == 4 || provider.tutorialStep == 5) {
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
              '${context.l10n.t('tourWelcomeTitle')} 🕊️',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFDDD6FE)
                    : const Color(0xFF5B21B6),
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('tourWelcomeDesc'),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
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
        isCircle = false;
        spotlightOffset = Offset(size.width / 2, size.height * 0.22);
        width = size.width - 24;
        height = 140;
        tooltipTop = size.height * 0.35;
        tooltipContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: isDark
                      ? const Color(0xFFC4B5FD)
                      : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.t('tourBannerTitle'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFDDD6FE)
                        : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('tourBannerDesc'),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
        break;

      case 2:
        isCircle = false;
        spotlightOffset = Offset(size.width / 2, 115);
        width = size.width;
        height = 40;
        tooltipTop = 150;
        tooltipContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wifi_rounded,
                  color: isDark
                      ? const Color(0xFFC4B5FD)
                      : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.t('tourNetworkTitle'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFDDD6FE)
                        : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('tourNetworkDesc'),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
        break;

      case 3:
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
                  color: isDark
                      ? const Color(0xFFC4B5FD)
                      : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.t('tourLiveTitle'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFDDD6FE)
                        : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('tourLiveDesc'),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
        break;

      case 6:
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
                  color: isDark
                      ? const Color(0xFFC4B5FD)
                      : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.t('tourSummaryTitle'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFDDD6FE)
                        : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('tourSummaryDesc'),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
        break;

      case 7:
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
                  color: isDark
                      ? const Color(0xFFC4B5FD)
                      : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.t('tourBibleTitle'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFDDD6FE)
                        : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('tourBibleDesc'),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
        break;

      case 8:
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
                  color: isDark
                      ? const Color(0xFFC4B5FD)
                      : const Color(0xFF6D28D9),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.t('tourExploreTitle'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFDDD6FE)
                        : const Color(0xFF5B21B6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('tourExploreDesc'),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
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
                    ? const Color(0xFF0F0A1C).withOpacity(
                        0.85,
                      ) // Dark purple tint
                    : const Color(
                        0xFF2E1A47,
                      ).withOpacity(0.55), // Deep purple tint in light mode
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
                  border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF8B5CF6).withOpacity(0.2)
                                : const Color(0xFFF3F0FF),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFFA78BFA)
                                  : const Color(0xFFC4B5FD),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            context.l10n.format('guideStep', {
                              'step': '${provider.tutorialStep + 1}',
                              'total': '9',
                            }),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFDDD6FE)
                                  : const Color(0xFF6D28D9),
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
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            size: 20,
                          ),
                          tooltip: context.l10n.t('skipTutorial'),
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
                              if (provider.tutorialStep == 6) {
                                // Go back to Step 5 (Timeline) on LiveTranslation screen
                                if (!provider.isRecording) {
                                  provider.toggleRecording();
                                }
                                Navigator.pushNamed(context, '/live');
                                provider.setTutorialStep(5);
                              } else if (provider.tutorialStep == 7) {
                                provider.setNavigationIndex(0);
                                provider.previousTutorialStep();
                              } else if (provider.tutorialStep == 8) {
                                provider.setNavigationIndex(1);
                                provider.previousTutorialStep();
                              } else {
                                provider.previousTutorialStep();
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? const Color(0xFFC4B5FD)
                                  : const Color(0xFF6D28D9),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              context.l10n.t('previous'),
                              style: const TextStyle(
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
                              foregroundColor: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              context.l10n.t('skip'),
                              style: const TextStyle(
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
                                  ? [
                                      const Color(0xFF8B5CF6),
                                      const Color(0xFFA78BFA),
                                    ]
                                  : [
                                      const Color(0xFF7C3AED),
                                      const Color(0xFF9061F9),
                                    ],
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
                              if (provider.tutorialStep < 8) {
                                if (provider.tutorialStep == 3) {
                                  provider.nextTutorialStep();
                                  if (!provider.isRecording) {
                                    provider.toggleRecording();
                                  }
                                  Navigator.pushNamed(context, '/live');
                                } else if (provider.tutorialStep == 6) {
                                  provider.setNavigationIndex(1);
                                  provider.nextTutorialStep();
                                } else if (provider.tutorialStep == 7) {
                                  provider.setNavigationIndex(2);
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
                                  provider.tutorialStep == 8
                                      ? '${context.l10n.t('getStarted')} 🎉'
                                      : context.l10n.t('nextFeature'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                if (provider.tutorialStep < 8) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                  ),
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
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (!noSpotlight) {
      if (isCircle) {
        path.addOval(Rect.fromCircle(center: spotlightOffset, radius: radius));
      } else {
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: spotlightOffset,
              width: width,
              height: height,
            ),
            const Radius.circular(16),
          ),
        );
      }
    }

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant SpotlightClipper oldClipper) => true;
}
