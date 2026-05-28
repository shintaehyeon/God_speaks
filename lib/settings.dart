import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/sermon_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Home focused'), duration: Duration(milliseconds: 500)),
            );
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('More settings (Prototype)'), duration: Duration(milliseconds: 500)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF2F69F8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2F69F8).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add_rounded, // Sleek Minimal Cross Emblem
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sermonProvider.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sermonProvider.userRole,
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
                      backgroundColor: const Color(0xFF2F69F8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(200, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
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
              children: const [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F69F8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActivityCard(
              Icons.play_circle_outline_rounded,
              'Sunday Service: Hope & Renewal',
              'Watched online • 2 days ago',
              const Color(0xFFEBF2FF),
              const Color(0xFF2F69F8),
            ),
            const SizedBox(height: 10),
            _buildActivityCard(
              Icons.menu_book_rounded,
              'Morning Devotional: Psalms 23',
              'Completed reading • 3 days ago',
              const Color(0xFFE2E8F0),
              const Color(0xFF475569),
            ),

            const SizedBox(height: 32),

            // 3. App Preferences Section
            const Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: Column(
                children: [
                  _buildPreferenceDropdownRow(
                    context,
                    Icons.translate_rounded,
                    'Translation Language',
                    sermonProvider.translationLanguage,
                    ['English', 'Spanish', 'French', 'Korean', 'Chinese'],
                    (val) {
                      if (val != null) {
                        sermonProvider.updateUserPreference(translationLanguage: val);
                      }
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildPreferenceOptionRow(
                    context,
                    Icons.nights_stay_outlined,
                    'Appearance',
                    sermonProvider.appearance,
                    () => _showAppearanceDialog(context, sermonProvider),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildPreferenceToggleRow(
                    Icons.notifications_none_rounded,
                    'Push Notifications',
                    sermonProvider.pushNotifications,
                    (val) {
                      sermonProvider.updateUserPreference(pushNotifications: val);
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildPreferenceToggleRow(
                    Icons.psychology_outlined,
                    '실시간 AI 연동 모드 (Gemini & STT)',
                    sermonProvider.useRealAI,
                    (val) {
                      sermonProvider.toggleRealAI(val);
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildPreferenceOptionRow(
                    context,
                    Icons.menu_book_outlined,
                    'Preferred Bible Version',
                    sermonProvider.preferredBibleVersion,
                    () => _showBibleVersionDialog(context, sermonProvider),
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
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2), // Soft pink/red background
                foregroundColor: const Color(0xFFEF4444), // Crimson text color
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 120), // Premium spacer to avoid bottom navigation overlay
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    IconData icon,
    String title,
    String subtitle,
    Color bgIconColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          )
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ),
          DropdownButton<String>(
            value: currentValue,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
            style: const TextStyle(color: Color(0xFF2F69F8), fontWeight: FontWeight.bold, fontSize: 13),
            onChanged: onChanged,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
            ),
            Row(
              children: [
                Text(
                  currentValue,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceToggleRow(
    IconData icon,
    String label,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2F69F8),
          ),
        ],
      ),
    );
  }

  // Preference selection Dialogs
  void _showAppearanceDialog(BuildContext context, SermonProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Appearance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['System Default', 'Light Mode', 'Dark Mode'].map((opt) {
              return ListTile(
                title: Text(opt),
                trailing: provider.appearance == opt ? const Icon(Icons.check, color: Color(0xFF2F69F8)) : null,
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
          title: const Text('Preferred Bible Version'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['NIV', 'ESV', 'KJV', 'NASB', '개역개정'].map((opt) {
              return ListTile(
                title: Text(opt),
                trailing: provider.preferredBibleVersion == opt ? const Icon(Icons.check, color: Color(0xFF2F69F8)) : null,
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
          title: const Text('Edit Profile Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.updateUserPreference(displayName: controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
