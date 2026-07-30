import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/church.dart';
import 'state/sermon_provider.dart';
import 'theme.dart';
import 'l10n/hispeak_localizations.dart';

class ChurchFinderPage extends StatefulWidget {
  const ChurchFinderPage({super.key});

  @override
  State<ChurchFinderPage> createState() => _ChurchFinderPageState();
}

class _ChurchFinderPageState extends State<ChurchFinderPage> {
  String _query = '';
  String _language = 'All';
  bool _nearbyMode = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SermonProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final churches = provider.churchDirectory.where((church) {
      final query = _query.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          church.name.toLowerCase().contains(query) ||
          church.regionLabel.toLowerCase().contains(query) ||
          church.denomination.toLowerCase().contains(query);
      final matchesLanguage =
          _language == 'All' || church.languages.contains(_language);
      return matchesQuery && matchesLanguage;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          context.l10n.t('churchFinder'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.t('addChurch'),
            icon: const Icon(Icons.add_location_alt_rounded),
            onPressed: () => _showSubmitChurchSheet(context, provider),
          ),
        ],
      ),
      body: Stack(
        children: [
          HISpeakTheme.buildIridescentBg(context),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                _buildMapPreview(context, isDark),
                const SizedBox(height: 16),
                _buildSearchBar(isDark),
                const SizedBox(height: 12),
                _buildLanguageFilters(isDark),
                const SizedBox(height: 18),
                _buildSubmissionStatus(provider, isDark),
                const SizedBox(height: 18),
                Text(
                  _nearbyMode
                      ? context.l10n.t('nearbyRecommended')
                      : context.l10n.t('registeredChurches'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                ...churches.map((church) => _ChurchCard(church: church)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: HISpeakTheme.purpleMain,
        foregroundColor: Colors.white,
        onPressed: () => _showSubmitChurchSheet(context, provider),
        icon: const Icon(Icons.edit_location_alt_rounded),
        label: Text(context.l10n.t('addChurch')),
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context, bool isDark) {
    return PremiumGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: HISpeakTheme.purpleMain.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: HISpeakTheme.purpleMain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.t('churchHeroTitle'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.l10n.t('churchHeroDesc'),
                      style: TextStyle(
                        fontSize: 12,
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
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDDEAFE), Color(0xFFFCE7F3)],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _MapLinesPainter()),
                ),
                const Positioned(
                  left: 38,
                  top: 34,
                  child: _MapPin(label: 'KR'),
                ),
                const Positioned(
                  right: 46,
                  top: 54,
                  child: _MapPin(label: 'EN'),
                ),
                const Positioned(
                  left: 132,
                  bottom: 28,
                  child: _MapPin(label: 'FR'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _nearbyMode = !_nearbyMode);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _nearbyMode
                          ? context.l10n.t('nearbyOnSnack')
                          : context.l10n.t('nearbyOffSnack'),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: Icon(
                _nearbyMode
                    ? Icons.location_on_rounded
                    : Icons.my_location_rounded,
              ),
              label: Text(
                _nearbyMode
                    ? context.l10n.t('nearbyOn')
                    : context.l10n.t('findNearby'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: HISpeakTheme.purpleMain,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: context.l10n.t('churchSearchHint'),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLanguageFilters(bool isDark) {
    final languages = ['All', 'Korean', 'English', 'French'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: languages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final language = languages[index];
          final selected = _language == language;
          return ChoiceChip(
            selected: selected,
            label: Text(_localizedLanguageFilter(context, language)),
            onSelected: (_) => setState(() => _language = language),
            selectedColor: HISpeakTheme.purpleMain,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF475569)),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            side: BorderSide(
              color: selected
                  ? HISpeakTheme.purpleMain
                  : const Color(0xFFE2E8F0),
            ),
          );
        },
      ),
    );
  }

  String _localizedLanguageFilter(BuildContext context, String language) {
    switch (language) {
      case 'All':
        return context.l10n.t('all');
      case 'Korean':
        return context.l10n.t('korean');
      case 'English':
        return context.l10n.t('english');
      case 'French':
        return context.l10n.t('french');
      default:
        return language;
    }
  }

  Widget _buildSubmissionStatus(SermonProvider provider, bool isDark) {
    final pendingCount = provider.myChurchSubmissions
        .where((church) => church.status == 'pending')
        .length;
    if (pendingCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.75)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pending_actions_rounded, color: Color(0xFFF59E0B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.format('pendingChurchCount', {
                'count': pendingCount.toString(),
              }),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitChurchSheet(BuildContext context, SermonProvider provider) {
    final nameController = TextEditingController();
    final denominationController = TextEditingController(text: 'Protestant');
    final languageController = TextEditingController(text: 'Korean, English');
    final timeController = TextEditingController(text: 'Sun 11:00');
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final countryController = TextEditingController(text: 'France');
    final noteController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.t('submitChurchTitle'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.t('submitChurchDesc'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetField(
                    controller: nameController,
                    label: context.l10n.t('churchName'),
                  ),
                  _SheetField(
                    controller: denominationController,
                    label: context.l10n.t('denomination'),
                  ),
                  _SheetField(
                    controller: languageController,
                    label: context.l10n.t('worshipLanguage'),
                    hint: 'Korean, English, French',
                  ),
                  _SheetField(
                    controller: timeController,
                    label: context.l10n.t('worshipTime'),
                    hint: 'Sun 11:00, Wed 19:30',
                  ),
                  _SheetField(
                    controller: addressController,
                    label: context.l10n.t('address'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _SheetField(
                          controller: cityController,
                          label: context.l10n.t('city'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SheetField(
                          controller: countryController,
                          label: context.l10n.t('country'),
                        ),
                      ),
                    ],
                  ),
                  _SheetField(
                    controller: noteController,
                    label: context.l10n.t('memo'),
                    hint: context.l10n.t('churchMemoHint'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final ok = await provider.submitChurch(
                        name: nameController.text,
                        denomination: denominationController.text,
                        languages: languageController.text.split(','),
                        worshipTimes: timeController.text.split(','),
                        address: addressController.text,
                        city: cityController.text,
                        country: countryController.text,
                        note: noteController.text,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? context.l10n.t('churchSubmitted')
                                : context.l10n.t('churchSubmitCheck'),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HISpeakTheme.purpleMain,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l10n.t('requestReview'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChurchCard extends StatelessWidget {
  final Church church;

  const _ChurchCard({required this.church});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSample = church.status == 'sample';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.82)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSample ? const Color(0xFFC4B5FD) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: HISpeakTheme.purpleMain.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.church_rounded,
                  color: HISpeakTheme.purpleMain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      church.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${church.denomination} · ${_churchRegionLabel(context, church)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSample)
                _StatusBadge(
                  label: context.l10n.t('sample'),
                  color: HISpeakTheme.purpleMain,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.translate_rounded,
                label: _churchLanguageLabel(context, church),
              ),
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: _churchWorshipLabel(context, church),
              ),
            ],
          ),
          if (church.address.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    church.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (church.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              church.note,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _churchLanguageLabel(BuildContext context, Church church) {
    if (church.languages.isEmpty) return context.l10n.t('languageNotSet');
    return church.languages
        .map((language) {
          switch (language) {
            case 'Korean':
              return context.l10n.t('korean');
            case 'English':
              return context.l10n.t('english');
            case 'French':
              return context.l10n.t('french');
            default:
              return language;
          }
        })
        .join(' / ');
  }

  String _churchWorshipLabel(BuildContext context, Church church) {
    if (church.worshipTimes.isEmpty) {
      return context.l10n.t('worshipTimeNotSet');
    }
    return church.worshipTimes.join(' · ');
  }

  String _churchRegionLabel(BuildContext context, Church church) {
    final parts = [
      church.city,
      church.country,
    ].where((part) => part.trim().isNotEmpty);
    return parts.isEmpty ? context.l10n.t('regionNotSet') : parts.join(', ');
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC).withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HISpeakTheme.purpleMain),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;

  const _SheetField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;

  const _MapPin({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: HISpeakTheme.purpleMain,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: 2,
          height: 14,
          color: HISpeakTheme.purpleMain.withOpacity(0.45),
        ),
      ],
    );
  }
}

class _MapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.58)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (double y = 24; y < size.height; y += 34) {
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width * 0.35, y - 18, size.width, y + 8);
      canvas.drawPath(path, paint);
    }

    for (double x = 32; x < size.width; x += 56) {
      final path = Path()
        ..moveTo(x, 0)
        ..quadraticBezierTo(x + 14, size.height * 0.5, x - 8, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
