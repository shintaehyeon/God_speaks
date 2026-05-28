import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/sermon_provider.dart';

class LiveTranslationPage extends StatefulWidget {
  const LiveTranslationPage({Key? key}) : super(key: key);

  @override
  State<LiveTranslationPage> createState() => _LiveTranslationPageState();
}

class _LiveTranslationPageState extends State<LiveTranslationPage> {
  bool _showFlowSummary = false;
  final ScrollController _timelineScrollController = ScrollController();
  final ScrollController _textScrollController = ScrollController();

  @override
  void dispose() {
    _timelineScrollController.dispose();
    _textScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);

    // Auto-scroll to the bottom of both sections when content updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_textScrollController.hasClients) {
        _textScrollController.animateTo(
          _textScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      if (_timelineScrollController.hasClients) {
        _timelineScrollController.animateTo(
          _timelineScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            // Stop translation session upon leaving page
            if (sermonProvider.isRecording) {
              sermonProvider.toggleRecording();
            }
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '실시간 번역 활성 중',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF2FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'KR ➔ EN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F69F8),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Live Sermon Flow Timeline (Top Half)
          Expanded(
            flex: 11,
            child: Scrollbar(
              controller: _timelineScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _timelineScrollController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '오늘의 설교 흐름',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '실시간 업데이트 중',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F69F8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Vertical Timeline Builder
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sermonProvider.sermonFlowSteps.length,
                    itemBuilder: (context, index) {
                      final step = sermonProvider.sermonFlowSteps[index];
                      final isLast = index == sermonProvider.sermonFlowSteps.length - 1;
                      
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left indicator (Icons + Line)
                            Column(
                              children: [
                                _buildTimelineIcon(step.type),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            
                            // Right Details Card
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isLast && step.type == 'pending'
                                          ? const Color(0xFF2F69F8).withOpacity(0.3)
                                          : const Color(0xFFF1F5F9),
                                      width: 1.5,
                                      style: isLast && step.type == 'pending'
                                          ? BorderStyle.solid
                                          : BorderStyle.none,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.time,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isLast && step.type == 'pending'
                                              ? const Color(0xFF2F69F8)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        step.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        step.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF475569),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

          // 2. Real-time Sound Waves visualizer (Middle transition)
          if (sermonProvider.isRecording)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sermonProvider.waveValues.length,
                  (index) {
                    final val = sermonProvider.waveValues[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: 3.5,
                      height: 10 + (val * 40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F69F8).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 3. Live Transcription Card (Bottom Half)
          Expanded(
            flex: 8,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.translate_rounded,
                                size: 16,
                                color: Color(0xFF2F69F8),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'LIVE TRANSCRIPTION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F69F8),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '(English)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Streaming text field
                      Expanded(
                        child: Scrollbar(
                          controller: _textScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _textScrollController,
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            child: Text(
                              sermonProvider.liveTranslationText.isEmpty
                                  ? "Waiting for sermon to begin..."
                                  : sermonProvider.liveTranslationText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Floating Bookmark/Save icon
                  Positioned(
                    right: 0,
                    bottom: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x15000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ]
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.bookmark_outline_rounded,
                          color: Color(0xFF2F69F8),
                          size: 24,
                        ),
                        onPressed: () {
                          // Quick toast feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('구절이 보관함에 임시 추가되었습니다.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // 4. Fixed Switch Mode bar at bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _buildToggleTab('번역 모드', !_showFlowSummary),
                  _buildToggleTab('흐름 요약', _showFlowSummary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab(String name, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showFlowSummary = (name == '흐름 요약');
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2F69F8) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineIcon(String type) {
    Color bg;
    IconData icon;
    
    if (type == 'topic') {
      bg = const Color(0xFF2F69F8);
      icon = Icons.numbers_rounded; // Represents '#'
    } else if (type == 'scripture') {
      bg = const Color(0xFFEBF2FF);
      icon = Icons.menu_book_rounded;
    } else {
      bg = const Color(0xFFE2E8F0);
      icon = Icons.more_horiz_rounded;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 16,
        color: type == 'topic' ? Colors.white : const Color(0xFF2F69F8),
      ),
    );
  }
}
