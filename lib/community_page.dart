import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/faith_group.dart';
import 'state/sermon_provider.dart';
import 'theme.dart';
import 'l10n/hispeak_localizations.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SermonProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGroup = provider.activeGroup;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          context.l10n.t('communityTitle'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.t('joinWithCode'),
            icon: const Icon(Icons.link_rounded),
            onPressed: () => _showJoinGroupDialog(context, provider),
          ),
          IconButton(
            tooltip: context.l10n.t('createGroup'),
            icon: const Icon(Icons.group_add_rounded),
            onPressed: () => _showCreateGroupDialog(context, provider),
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
                if (activeGroup == null)
                  _EmptyCommunityState(provider: provider)
                else ...[
                  _GroupHeader(group: activeGroup),
                  const SizedBox(height: 16),
                  _VoyageBoard(members: provider.groupMembers),
                  const SizedBox(height: 16),
                  _ActionRow(provider: provider),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.t('qtFeed'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (provider.qtPosts.isEmpty)
                    _EmptyPostCard(isDark: isDark)
                  else
                    ...provider.qtPosts.map((post) => _QtPostCard(post: post)),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: activeGroup == null
          ? FloatingActionButton.extended(
              backgroundColor: HISpeakTheme.purpleMain,
              foregroundColor: Colors.white,
              onPressed: () => _showCreateGroupDialog(context, provider),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.t('createGroup')),
            )
          : FloatingActionButton.extended(
              backgroundColor: HISpeakTheme.purpleMain,
              foregroundColor: Colors.white,
              onPressed: () => _showQtShareSheet(context, provider),
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(context.l10n.t('shareQt')),
            ),
    );
  }

  static void _showCreateGroupDialog(
    BuildContext context,
    SermonProvider provider,
  ) {
    final controller = TextEditingController(
      text: context.l10n.t('voyageBoard'),
    );
    showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            context.l10n.t('groupDialogTitle'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: context.l10n.t('groupName'),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final ok = await provider.createFamilyGroup(controller.text);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? context.l10n.t('groupCreated')
                          : context.l10n.t('groupCreateFailed'),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HISpeakTheme.purpleMain,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.t('create')),
            ),
          ],
        );
      },
    );
  }

  static void _showJoinGroupDialog(
    BuildContext context,
    SermonProvider provider,
  ) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            context.l10n.t('inviteDialogTitle'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: context.l10n.t('inviteCode'),
              hintText: context.l10n.t('inviteCodeHint'),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final ok = await provider.joinGroupWithInviteToken(
                  controller.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? context.l10n.t('joinSuccess')
                          : context.l10n.t('joinFailed'),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HISpeakTheme.purpleMain,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.t('join')),
            ),
          ],
        );
      },
    );
  }

  static void _showQtShareSheet(BuildContext context, SermonProvider provider) {
    final verseController = TextEditingController(text: '시편 23:1');
    final contentController = TextEditingController();

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.t('qtShareTitle'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: verseController,
                  decoration: _sheetDecoration(
                    context,
                    context.l10n.t('verseRef'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: _sheetDecoration(
                    context,
                    context.l10n.t('graceToday'),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await provider.shareQtPost(
                      verseRef: verseController.text,
                      content: contentController.text,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? context.l10n.t('qtShared')
                              : context.l10n.t('qtEmptyInput'),
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
                    context.l10n.t('share'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static InputDecoration _sheetDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _EmptyCommunityState extends StatelessWidget {
  final SermonProvider provider;

  const _EmptyCommunityState({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: HISpeakTheme.purpleMain,
            ),
            child: const Icon(
              Icons.directions_boat_filled_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.t('communityEmptyTitle'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.t('communityEmptyDesc'),
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 18),
          _SampleVoyagePreview(isDark: isDark),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  CommunityPage._showCreateGroupDialog(context, provider),
              icon: const Icon(Icons.group_add_rounded),
              label: Text(context.l10n.t('createGroup')),
              style: ElevatedButton.styleFrom(
                backgroundColor: HISpeakTheme.purpleMain,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  CommunityPage._showJoinGroupDialog(context, provider),
              icon: const Icon(Icons.link_rounded),
              label: Text(context.l10n.t('joinWithCode')),
              style: OutlinedButton.styleFrom(
                foregroundColor: HISpeakTheme.purpleMain,
                side: const BorderSide(color: HISpeakTheme.purpleMain),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final FaithGroup group;

  const _GroupHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: HISpeakTheme.purpleMain.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_2_rounded,
                  color: HISpeakTheme.purpleMain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.l10n.format('membersReading', {
                        'count': group.memberIds.length.toString(),
                      }),
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
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: group.inviteToken));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.t('inviteCopied'))),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withOpacity(0.5)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    size: 18,
                    color: HISpeakTheme.purpleMain,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.format('inviteCodeLabel', {
                        'code': group.inviteToken,
                      }),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFDDD6FE)
                            : HISpeakTheme.purpleMain,
                      ),
                    ),
                  ),
                  const Icon(Icons.copy_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoyageBoard extends StatelessWidget {
  final List<GroupMember> members;

  const _VoyageBoard({required this.members});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayMembers = members.isEmpty
        ? [
            GroupMember(
              id: 'sample',
              userId: 'sample',
              displayName: context.l10n.t('me'),
              currentBook: context.l10n.t('matthew'),
              currentChapter: 1,
              progressPercent: 0.03,
              role: 'owner',
              updatedAt: DateTime(2000),
            ),
          ]
        : members;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.78)
            : Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.t('voyageBoard'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          ...displayMembers.map((member) => _VoyageMemberRow(member: member)),
        ],
      ),
    );
  }
}

class _VoyageMemberRow extends StatelessWidget {
  final GroupMember member;

  const _VoyageMemberRow({required this.member});

  @override
  Widget build(BuildContext context) {
    final percent = member.progressPercent.clamp(0.0, 1.0).toDouble();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8B5CF6),
                ),
                alignment: Alignment.center,
                child: Text(
                  member.displayName.characters.first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayMemberName(context, member.displayName),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      context.l10n.format('readingStatus', {
                        'book': _displayBookName(context, member.currentBook),
                        'chapter': member.currentChapter.toString(),
                      }),
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
              const Icon(
                Icons.directions_boat_filled_rounded,
                color: HISpeakTheme.purpleMain,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 9,
              backgroundColor: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                HISpeakTheme.purpleMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayBookName(BuildContext context, String bookName) {
    return bookName == '마태복음' ? context.l10n.t('matthew') : bookName;
  }

  String _displayMemberName(BuildContext context, String name) {
    return name == '성도' ? context.l10n.t('believer') : name;
  }
}

class _ActionRow extends StatelessWidget {
  final SermonProvider provider;

  const _ActionRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final ok = await provider.markNextChapterRead();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? context.l10n.t('nextChapterSaved')
                        : context.l10n.t('progressSaveFailed'),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.flag_rounded),
            label: Text(context.l10n.t('nextChapter')),
            style: ElevatedButton.styleFrom(
              backgroundColor: HISpeakTheme.purpleMain,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => CommunityPage._showQtShareSheet(context, provider),
            icon: const Icon(Icons.forum_rounded),
            label: Text(context.l10n.t('shareQt')),
            style: OutlinedButton.styleFrom(
              foregroundColor: HISpeakTheme.purpleMain,
              side: const BorderSide(color: HISpeakTheme.purpleMain),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QtPostCard extends StatelessWidget {
  final QtPost post;

  const _QtPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.82)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: HISpeakTheme.purpleMain,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post.verseRef.isEmpty
                      ? context.l10n.t('qtShareTitle')
                      : post.verseRef,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: HISpeakTheme.purpleMain,
                  ),
                ),
              ),
              Text(
                post.authorName == '성도'
                    ? context.l10n.t('believer')
                    : post.authorName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPostCard extends StatelessWidget {
  final bool isDark;

  const _EmptyPostCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.72)
            : Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        context.l10n.t('qtEmpty'),
        style: const TextStyle(
          fontSize: 13,
          height: 1.45,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _SampleVoyagePreview extends StatelessWidget {
  final bool isDark;

  const _SampleVoyagePreview({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withOpacity(0.42)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _PreviewLine(
            name: 'A',
            label: context.l10n.format('readingStatus', {
              'book': context.l10n.t('matthew'),
              'chapter': '3',
            }),
            value: 0.18,
          ),
          const SizedBox(height: 10),
          _PreviewLine(
            name: 'B',
            label: context.l10n.format('readingStatus', {
              'book': context.l10n.t('matthew'),
              'chapter': '1',
            }),
            value: 0.06,
          ),
          const SizedBox(height: 10),
          _PreviewLine(
            name: 'C',
            label: context.l10n.format('readingStatus', {
              'book': context.l10n.t('matthew'),
              'chapter': '5',
            }),
            value: 0.31,
          ),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  final String name;
  final String label;
  final double value;

  const _PreviewLine({
    required this.name,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: HISpeakTheme.purpleMain,
          ),
          alignment: Alignment.center,
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                HISpeakTheme.purpleMain,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
