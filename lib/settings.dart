import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'state/sermon_provider.dart';
import 'theme.dart';
import 'l10n/hispeak_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          HISpeakTheme.buildIridescentBg(context),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                context.l10n.t('settingsTitle'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              actions: [],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Profile Header
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(context, sermonProvider),
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: sermonProvider.profileImagePath == null
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF8B5CF6),
                                        Color(0xFF6D28D9),
                                      ],
                                    )
                                  : null,
                              image:
                                  sermonProvider.profileImagePath != null &&
                                      File(
                                        sermonProvider.profileImagePath!,
                                      ).existsSync()
                                  ? DecorationImage(
                                      image: FileImage(
                                        File(sermonProvider.profileImagePath!),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ).withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: sermonProvider.profileImagePath == null
                                ? const Icon(
                                    Icons
                                        .add_rounded, // Sleek Minimal Cross Emblem
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          sermonProvider.displayName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.t('memberRole'),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _showEditNameDialog(context, sermonProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HISpeakTheme.purpleMain,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(200, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            context.l10n.t('editProfile'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 2. Recent Activity Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.t('recentActivity'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          sermonProvider.setNavigationIndex(2); // 지난 요약본 탭으로 이동
                        },
                        child: Text(
                          context.l10n.t('viewAll'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: HISpeakTheme.purpleMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildActivityCard(
                    context,
                    Icons.article_rounded,
                    context.l10n.t('goodShepherdTitle'),
                    '2026-06-11 • FAITH • ${context.l10n.t('summaryComplete')}',
                    isDark ? const Color(0xFF1E1B4B) : const Color(0xFFF5F3FF),
                    HISpeakTheme.purpleMain,
                    onTap: () {
                      sermonProvider.setNavigationIndex(2); // 지난 요약본 탭으로 이동
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildActivityCard(
                    context,
                    Icons.mic_none_rounded,
                    context.l10n.t('liveSttSummary'),
                    '2026-06-08 • LIVE STT • ${context.l10n.t('summaryComplete')}',
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    onTap: () {
                      sermonProvider.setNavigationIndex(2); // 지난 요약본 탭으로 이동
                    },
                  ),

                  const SizedBox(height: 32),

                  // 3. App Preferences Section
                  Text(
                    context.l10n.t('appPreferences'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withOpacity(0.85)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.12)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildPreferenceOptionRow(
                          context,
                          Icons.language_rounded,
                          context.l10n.t('appLanguage'),
                          _localizedAppLanguageName(
                            context,
                            sermonProvider.appLanguageCode,
                          ),
                          () => _showAppLanguageDialog(context, sermonProvider),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildPreferenceDropdownRow(
                          context,
                          Icons.translate_rounded,
                          context.l10n.t('translationLanguage'),
                          sermonProvider.translationLanguage,
                          ['Korean', 'Japanese', 'French'],
                          (val) {
                            if (val != null) {
                              sermonProvider.updateUserPreference(
                                translationLanguage: val,
                              );
                            }
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildPreferenceOptionRow(
                          context,
                          Icons.nights_stay_outlined,
                          context.l10n.t('appearance'),
                          _localizedAppearanceName(
                            context,
                            sermonProvider.appearance,
                          ),
                          () => _showAppearanceDialog(context, sermonProvider),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildPreferenceToggleRow(
                          context,
                          Icons.psychology_outlined,
                          context.l10n.t('realAiSetting'),
                          sermonProvider.useRealAI,
                          (val) {
                            sermonProvider.toggleRealAI(val);
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildPreferenceOptionRow(
                          context,
                          Icons.menu_book_outlined,
                          context.l10n.t('preferredBibleVersion'),
                          sermonProvider.preferredBibleVersion,
                          () =>
                              _showBibleVersionDialog(context, sermonProvider),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildPreferenceOptionRow(
                          context,
                          Icons.bookmark_rounded,
                          context.l10n.t('savedVersesQuotes'),
                          context.l10n.t('archive'),
                          () {
                            Navigator.pushNamed(context, '/archive');
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildPreferenceOptionRow(
                          context,
                          Icons.help_outline_rounded,
                          context.l10n.t('tutorialAgain'),
                          context.l10n.t('startGuide'),
                          () {
                            sermonProvider.triggerTutorial();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.t('tutorialStartSnack'),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 4. Logout Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await sermonProvider.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: Text(context.l10n.t('logout')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFFEF2F2,
                      ), // Soft pink/red background
                      foregroundColor: const Color(
                        0xFFEF4444,
                      ), // Crimson text color
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 120,
                  ), // Premium spacer to avoid bottom navigation overlay
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color bgIconColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withOpacity(0.85)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.12)
                : const Color(0xFFF1F5F9),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgIconColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceDropdownRow(
    BuildContext context,
    IconData icon,
    String label,
    String currentValue,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          DropdownButton<String>(
            value: currentValue,
            underline: const SizedBox(),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              size: 18,
            ),
            style: TextStyle(
              color: HISpeakTheme.purpleMain,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            onChanged: onChanged,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  _localizedTranslationLanguageName(context, value),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceOptionRow(
    BuildContext context,
    IconData icon,
    String label,
    String currentValue,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  currentValue,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceToggleRow(
    BuildContext context,
    IconData icon,
    String label,
    bool value,
    void Function(bool) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: HISpeakTheme.purpleMain,
          ),
        ],
      ),
    );
  }

  String _localizedAppLanguageName(BuildContext context, String code) {
    switch (code) {
      case 'ja':
        return '日本語';
      case 'fr':
        return 'Français';
      default:
        return '한국어';
    }
  }

  String _localizedTranslationLanguageName(BuildContext context, String value) {
    switch (value) {
      case 'Korean':
        return context.l10n.t('korean');
      case 'Japanese':
        return context.l10n.t('japanese');
      case 'French':
        return context.l10n.t('french');
      default:
        return value;
    }
  }

  String _localizedAppearanceName(BuildContext context, String appearance) {
    final code = context.l10n.languageCode;
    final labels = {
      'ko': {
        'System Default': '시스템 기본값',
        'Light Mode': '라이트 모드',
        'Dark Mode': '다크 모드',
      },
      'ja': {
        'System Default': 'システム設定',
        'Light Mode': 'ライトモード',
        'Dark Mode': 'ダークモード',
      },
      'fr': {
        'System Default': 'Par défaut',
        'Light Mode': 'Mode clair',
        'Dark Mode': 'Mode sombre',
      },
    };
    return labels[code]?[appearance] ?? appearance;
  }

  void _showAppLanguageDialog(BuildContext context, SermonProvider provider) {
    final options = {'ko': '한국어', 'ja': '日本語', 'fr': 'Français'};
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.t('appLanguage')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                trailing: provider.appLanguageCode == entry.key
                    ? const Icon(Icons.check, color: Color(0xFF2F69F8))
                    : null,
                onTap: () {
                  provider.updateUserPreference(appLanguageCode: entry.key);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Preference selection Dialogs
  void _showAppearanceDialog(BuildContext context, SermonProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.t('selectAppearance')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['System Default', 'Light Mode', 'Dark Mode'].map((opt) {
              return ListTile(
                title: Text(_localizedAppearanceName(context, opt)),
                trailing: provider.appearance == opt
                    ? const Icon(Icons.check, color: Color(0xFF2F69F8))
                    : null,
                onTap: () {
                  provider.updateUserPreference(appearance: opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showBibleVersionDialog(BuildContext context, SermonProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.t('preferredBibleVersion')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                [
                  '한영대조',
                  'Korean Revised Version 1952/1961',
                  'World English Bible',
                ].map((opt) {
                  return ListTile(
                    title: Text(opt),
                    trailing: provider.preferredBibleVersion == opt
                        ? const Icon(Icons.check, color: Color(0xFF2F69F8))
                        : null,
                    onTap: () {
                      provider.updateUserPreference(preferredBibleVersion: opt);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, SermonProvider provider) {
    final controller = TextEditingController(text: provider.displayName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.t('editProfileName')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: context.l10n.t('displayName'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.t('cancel')),
            ),
            TextButton(
              onPressed: () {
                provider.updateUserPreference(
                  displayName: controller.text.trim(),
                );
                Navigator.pop(context);
              },
              child: Text(context.l10n.t('save')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, SermonProvider provider) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        await provider.updateUserPreference(profileImagePath: image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('profileImageUpdated'))),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }
}
