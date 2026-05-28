import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/sermon_provider.dart';
import 'models/saved_item.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({Key? key}) : super(key: key);

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);

    // Filter items based on type
    final verses = sermonProvider.archiveItems.where((item) => item.type == 'verse').toList();
    final quotes = sermonProvider.archiveItems.where((item) => item.type == 'quote').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            // Prototype back action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Back to Home'), duration: Duration(milliseconds: 500)),
            );
          },
        ),
        title: const Text(
          'Sermon Archive',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search archive (Prototype)'), duration: Duration(milliseconds: 500)),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF2F69F8),
          indicatorWeight: 3,
          labelColor: const Color(0xFF2F69F8),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Inter'),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Inter'),
          tabs: const [
            Tab(text: 'Bible Verses'),
            Tab(text: 'Key Quotes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemTab(verses, sermonProvider),
          _buildItemTab(quotes, sermonProvider),
        ],
      ),
    );
  }

  Widget _buildItemTab(List<SavedItem> items, SermonProvider provider) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bookmark_border_rounded, size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text(
              'No items archived yet',
              style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSaved = provider.savedItemIds.contains(item.id);
        
        // Custom UI designs matching the screenshots
        if (item.type == 'verse') {
          // Special John 3:16 header with beautiful cover photo
          final isJohn316 = item.title.contains('John 3:16');
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isJohn316) ...[
                  // Cover Image Container
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/bible_verse.png',
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Blue tint overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      // Verse of the Day Badge
                      Positioned(
                        left: 16,
                        top: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F69F8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VERSE OF THE DAY',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      // John 3:16 Title overlay
                      Positioned(
                        left: 16,
                        top: 86,
                        child: Text(
                          item.title.replaceAll('VERSE OF THE DAY: ', ''),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Service label for generic non-cover verses
                      if (!isJohn316) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.serviceType,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F69F8),
                              ),
                            ),
                            Text(
                              item.date,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ] else ...[
                        // Sunday service label underneath cover
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.serviceType,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              item.date,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                      
                      // Verse Text Content
                      Text(
                        item.content,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Footer action panel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.authorOrVersion,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF64748B)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied verse link!'), duration: Duration(seconds: 1)),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              _buildSaveButton(isSaved, () => provider.toggleSaveItem(item.id)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Quote Card Design (With double quote decoration)
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEBF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.format_quote_rounded, size: 14, color: Color(0xFF2F69F8)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.date,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Quote text
                Text(
                  item.content,
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '— ' + item.authorOrVersion,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF64748B)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied quote!'), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        _buildSaveButton(isSaved, () => provider.toggleSaveItem(item.id)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSaveButton(bool isSaved, VoidCallback onPressed) {
    if (isSaved) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.bookmark_rounded, size: 14),
        label: const Text('Saved'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F69F8),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.bookmark_border_rounded, size: 14),
        label: const Text('Save'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2F69F8),
          side: const BorderSide(color: Color(0xFF2F69F8), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }
  }
}
