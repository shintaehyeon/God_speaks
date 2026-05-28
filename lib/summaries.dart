import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/sermon_provider.dart';
import 'models/sermon_summary.dart';

class SummariesPage extends StatefulWidget {
  const SummariesPage({Key? key}) : super(key: key);

  @override
  State<SummariesPage> createState() => _SummariesPageState();
}

class _SummariesPageState extends State<SummariesPage> {
  String _selectedFilter = "All Archive";
  String _searchQuery = "";
  String? _expandedId; // ID of the currently expanded sermon card

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);

    // Filter summaries based on category and search query
    List<SermonSummary> filteredList = sermonProvider.summaries.where((s) {
      bool matchesFilter = _selectedFilter == "All Archive" ||
          s.category.toUpperCase() == _selectedFilter.toUpperCase();
      
      bool matchesSearch = s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.keyScripture.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.bulletPoints.any((pt) => pt.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu clicked (Prototype)'), duration: Duration(milliseconds: 500)),
            );
          },
        ),
        title: const Text(
          'Smart Summaries',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                // Focus profile setting page tab
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Swipe to settings tab to view profile'), duration: Duration(seconds: 1)),
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEBF2FF),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Color(0xFF2F69F8),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by date, topic, or scripture',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                filled: true,
                fillColor: const Color(0xFFF8F9FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // 2. Horizontal Filter Categories
          Container(
            color: Colors.white,
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip("All Archive"),
                _buildFilterChip("Theology", hasArrow: true),
                _buildFilterChip("Recent", hasCalendar: true),
                _buildFilterChip("Faith"),
                _buildFilterChip("Wisdom"),
                _buildFilterChip("Purpose"),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 3. Summaries Timeline / Card List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.feed_outlined, size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 12),
                        Text(
                          'No summaries found',
                          style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final s = filteredList[index];
                      final isExpanded = _expandedId == s.id;

                      // Expand the first card by default initially
                      if (_expandedId == null && index == 0) {
                        _expandedId = s.id;
                      }

                      return _buildSermonCard(s, isExpanded);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String name, {bool hasArrow = false, bool hasCalendar = false}) {
    final isSelected = _selectedFilter == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F69F8) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCalendar) ...[
              Icon(
                Icons.calendar_today_rounded,
                size: 11,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            if (hasArrow) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSermonCard(SermonSummary s, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          key: PageStorageKey(s.id),
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedId = expanded ? s.id : null;
            });
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    s.date,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F69F8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 3.5,
                    height: 3.5,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s.category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                s.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFF1F5F9), height: 20),
                  
                  // Bullet Points Summaries
                  ...s.bulletPoints.map((pt) {
                    bool isBoldKey = pt.startsWith("Key scripture:") || pt.startsWith("Closing takeaway:");
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2F69F8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  if (isBoldKey) ...[
                                    TextSpan(
                                      text: '${pt.split(':')[0]}:',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    TextSpan(
                                      text: pt.substring(pt.indexOf(':')),
                                      style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 13,
                                        height: 1.4,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ] else
                                    TextSpan(
                                      text: pt,
                                      style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 13,
                                        height: 1.4,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 8),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Playing sermon audio... (Prototype)'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                        label: const Text('Listen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEBF2FF),
                          foregroundColor: const Color(0xFF2F69F8),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Summary link copied to clipboard!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 14),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
