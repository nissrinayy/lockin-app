import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_list_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'User';
  bool _isPremium = false;
  final List<int> _weeklyFocusHours = [5, 12, 6, 13, 10, 7, 5];
  bool _showTodo = true; // true = To-Do view, false = Journal view
  bool _showBarChart = true; // true = Bar chart, false = Line chart
  
  final Map<String, TextWeights> _dayTextWeights = const {
    'Monday': TextWeights(title: FontWeight.w500, subtitle: FontWeight.w500, status: FontWeight.w500),
    'Tuesday': TextWeights(title: FontWeight.w500, subtitle: FontWeight.w500, status: FontWeight.w500),
    'Wednesday': TextWeights(title: FontWeight.w500, subtitle: FontWeight.w500, status: FontWeight.w500),
  };
  
  // Add journal text weights for consistent styling
  final JournalTextWeights _journalTextWeights = const JournalTextWeights(
    title: FontWeight.w400,
    subtitle: FontWeight.w500,
    preview: FontWeight.w400,
    emoji: FontWeight.w400,
  );
  
  // Remove the complex mood-based font weight system
  // Use consistent weights for all journal entries
  
  final Map<String, bool> _todoExpanded = {
    'Monday': true,
    'Tuesday': false,
    'Wednesday': false,
  };
  final List<_JournalEntry> _journalEntries = [
    _JournalEntry(
      title: 'Wonderfull Learning Day!😍',
      dateSubtitle: 'Today, July 11',
      preview: 'Seru banget aku belajar banyak hal hari ini. Pagi hari aku belajar speaking English lewat podcast dan latihan...',
      emoji: '🥰',
    ),
    _JournalEntry(
      title: 'Productive Brainstorming & Networking',
      dateSubtitle: 'Friday, July 11',
      preview: 'Diskusi bareng tim menghasilkan banyak ide. Aku juga kenalan dengan mentor baru yang kasih insight...',
      emoji: '🤑',
    ),
    _JournalEntry(
      title: 'Mixed Emotions & Self-Care Day',
      dateSubtitle: 'Thursday, July 10',
      preview: 'Hari ini cukup roller coaster, jadi kuakhiri dengan journaling dan jalan sore.',
      emoji: '🌞',
    ),
  ];
  final List<bool> _journalExpanded = [true, false, false];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      print('Loading state...');
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('name') ?? '';
      final premium = prefs.getBool('isPremium') ?? false;
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      
      print('Loaded from SharedPreferences: name="$storedName", premium=$premium, isFirstTime=$isFirstTime');
      
      if (!mounted) {
        print('Widget not mounted during load, returning');
        return;
      }
      
      setState(() {
        _userName = storedName.isNotEmpty ? storedName : 'User';
        // Show locked card for first-time users or non-premium users
        _isPremium = premium && !isFirstTime;
        print('State loaded: _userName="$_userName", _isPremium=$_isPremium');
      });
    } catch (e) {
      print('Error loading state: $e');
      // Set default values if loading fails
      if (mounted) {
        setState(() {
          _userName = 'User';
          _isPremium = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    print('Building HomePage: _isPremium = $_isPremium');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(width),
                SizedBox(height: height * 0.02),
                _isPremium 
                  ? (() {
                      print('Showing unlocked insight card');
                      return _buildUnlockedInsightCard(width);
                    })()
                  : (() {
                      print('Showing locked insight card');
                      return _buildLockedInsightCard(width);
                    })(),
                SizedBox(height: height * 0.02),
                _buildThisWeekSection(width, height),
              ],
            ),
          ),
        ),
      ),
             floatingActionButton: FloatingActionButton(
         backgroundColor: const Color(0xFF6A86F8),
         onPressed: () {
           _showAddOptions(context);
         },
         child: Icon(Icons.add, color: Colors.white),
       ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: width * 0.055,
          backgroundColor: const Color(0xFFE7EEFF),
          child: Text(
            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
            style: TextStyle(fontWeight: FontWeight.w700, color: const Color(0xFF3A5BEA)),
          ),
        ),
        SizedBox(width: width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ' + _userName,
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'How can I help you today?',
                style: TextStyle(
                  fontSize: width * 0.032,
                  color: const Color(0xFF6E6E6E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
                 IconButton(
           onPressed: () {},
           icon: Icon(Icons.notifications_none, color: Colors.black87),
         ),
      ],
    );
  }

  Widget _buildLockedInsightCard(double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5E86FF), Color(0xFFB08BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.lock, color: Colors.white, size: width * 0.09),
          ),
          SizedBox(height: 12),
          Text(
            'Unlock Your Performance Insight',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Get deep analysis of your focus patterns and see your weekly productivity trends',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: width * 0.033,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 14),
          SizedBox(
            width: width * 0.45,
            height: 40,
            child: ElevatedButton(
              onPressed: _upgradeToPremium,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5E86FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(
                'Get Premium',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: width * 0.038),
              ),
            ),
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildUnlockedInsightCard(double width) {
    final maxVal = (_weeklyFocusHours.reduce((a, b) => a > b ? a : b)).toDouble();
    final barMaxHeight = 60.0; // Reduced from 100 to 60 (1/3 smaller)
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.025), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5E86FF), Color(0xFFB08BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12), // Reduced from 18 to 12
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'AI-Powered Weekly',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.055, // Reduced from 0.055 to 0.035
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Snapshot',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.055, // Reduced from 0.055 to 0.035
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6), // Reduced from 10 to 6
          // Summary tiles: Activity & Mood
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width * 0.27, // Fixed width instead of Expanded
                child: _buildSummaryTile(
                  width,
                  emoji: '🔥',
                  label: 'Minggu Anda:',
                  value: _activitySummary(),
                ),
              ),
              SizedBox(width: 6), // Reduced from 8 to 6
              Container(
                width: width * 0.27, // Fixed width instead of Expanded
                child: _buildSummaryTile(
                  width,
                  emoji: '🥰',
                  label: 'Mood Anda:',
                  value: _moodSummary(),
                ),
              ),
            ],
          ),
          SizedBox(height: 6), // Reduced from 10 to 6
          Container(
            padding: EdgeInsets.all(8), // Reduced from 10 to 8
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8), // Reduced from 12 to 8
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Rata-Rata Fokus Anda:', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 12)), // Added fontSize
                SizedBox(height: 2), // Reduced from 4 to 2
                Text('8 Jam Waktu Fokus/Hari', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11)), // Added fontSize
                SizedBox(height: 8), // Reduced from 12 to 8
                // Chart area with improved swipe detection
                GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // Use velocity for better swipe detection
                    if (details.velocity.pixelsPerSecond.dx > 300 && !_showBarChart) {
                      setState(() => _showBarChart = true);
                    } else if (details.velocity.pixelsPerSecond.dx < -300 && _showBarChart) {
                      setState(() => _showBarChart = false);
                    }
                  },
                  onTap: () {
                    // Also allow tap to toggle chart type
                    setState(() => _showBarChart = !_showBarChart);
                  },
                                                       child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(6), // Reduced from 8 to 6
                    ),
                     child: Column(
                       children: [
                                                 // Chart indicator at the top
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 2), // Reduced from 4 to 2
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.all(2), // Reduced from 4 to 2
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(2), // Reduced from 4 to 2
                                ),
                                child: Icon(
                                  _showBarChart ? Icons.show_chart : Icons.bar_chart,
                                  size: 8, // Reduced from 12 to 8
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: 4), // Reduced from 8 to 4
                            ],
                          ),
                        ),
                                                 // Chart content with proper sizing
                        Container(
                          height: barMaxHeight + 12, // Reduced height
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced padding
                          child: _showBarChart 
                            ? _buildBarChart(barMaxHeight, maxVal)
                            : _buildLineChart(barMaxHeight, maxVal),
                        ),
                       ],
                     ),
                   ),
                ),
                                  SizedBox(height: 2), // Reduced from 4 to 2
                // Small instruction text
                Text(
                  'Swipe left/right or tap to change chart type',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8, // Reduced from 10 to 8
                    color: Colors.grey.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
               ],
             ),
           ),
         ],
       ),
     );
   }

  Widget _buildSummaryTile(double width, {required String emoji, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6), // Reduced from 10 to 6
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), // Reduced from 12 to 8
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: width * 0.07)), // Reduced from 0.11 to 0.07
          SizedBox(height: 2), // Reduced from 4 to 2
          Text(label, style: TextStyle(color: const Color(0xFF8BA1B0), fontWeight: FontWeight.w500, fontSize: 9)), // Reduced from 11 to 9
          SizedBox(height: 1), // Reduced from 2 to 1
          Text(value, textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 10)), // Reduced from 12 to 10
        ],
      ),
    );
  }

  Widget _buildBarChart(double maxHeight, double maxVal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final value = _weeklyFocusHours[index].toDouble();
        final barHeight = (value / maxVal * (maxHeight - 12)).clamp(3.0, maxHeight - 12); // Adjusted for smaller size
        const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, // Reduced from 12 to 8
              height: barHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF6A86F8),
                borderRadius: BorderRadius.circular(3), // Reduced from 4 to 3
              ),
            ),
            SizedBox(height: 2), // Reduced from 4 to 2
            Text(
              labels[index], 
              style: TextStyle(fontSize: 6, color: Colors.black54), // Reduced from 8 to 6
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLineChart(double maxHeight, double maxVal) {
    return CustomPaint(
      size: Size(double.infinity, maxHeight - 12), // Adjusted for smaller size
      painter: LineChartPainter(
        data: _weeklyFocusHours,
        maxValue: maxVal,
        maxHeight: maxHeight - 12, // Adjusted height
        color: const Color(0xFF6A86F8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(7, (index) {
          const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          return Text(
            labels[index], 
            style: TextStyle(fontSize: 6, color: Colors.black54), // Reduced from 8 to 6
            textAlign: TextAlign.center,
          );
        }),
      ),
    );
  }

  String _activitySummary() {
    // Simple heuristic based on average weekly focus hours
    final avg = _weeklyFocusHours.reduce((a, b) => a + b) / _weeklyFocusHours.length;
    if (avg >= 8) return 'Sangat Produktif';
    if (avg >= 6) return 'Produktif';
    return 'Perlu Ditingkatkan';
  }

  String _moodSummary() {
    // Map emoji to sentiment score, then summarize description
    double scoreSum = 0;
    for (final e in _journalEntries) {
      scoreSum += _emojiSentiment(e.emoji);
    }
    final avg = scoreSum / _journalEntries.length;
    if (avg >= 1.7) return 'Sangat Positif';
    if (avg >= 1.2) return 'Positif & Reflektif';
    return 'Netral / Campur Aduk';
  }

  double _emojiSentiment(String emoji) {
    switch (emoji) {
      case '🥰':
        return 2.0;
      case '🌞':
        return 1.6;
      case '🤑':
        return 1.3;
      default:
        return 1.0;
    }
  }

  Widget _buildThisWeekSection(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('This Week', style: TextStyle(fontWeight: FontWeight.w500, fontSize: width * 0.05)),
            _buildSegmentedToggle(width)
          ],
        ),
        SizedBox(height: 12),
        if (_showTodo) ...[
          _buildDayCard(width, 'Monday', 'You still have 1 task left', 'In Progress', [
            _TaskItem('Workout', '03:00 PM', done: false),
            _TaskItem('Read book', '10:00 AM', done: true),
          ],
              weights: _dayTextWeights['Monday'] ?? const TextWeights(),
              expanded: _todoExpanded['Monday'] ?? false,
              onToggle: () {
                setState(() {
                  _todoExpanded['Monday'] = !(_todoExpanded['Monday'] ?? false);
                });
              }),
          SizedBox(height: 12),
          _buildDayCard(width, 'Tuesday', 'You have 5 tasks to complete', 'Not Started', [
            _TaskItem('Plan sprint backlog', '09:00 AM'),
          ], weights: _dayTextWeights['Tuesday'] ?? const TextWeights(),
              expanded: _todoExpanded['Tuesday'] ?? false,
              onToggle: () {
                setState(() {
                  _todoExpanded['Tuesday'] = !(_todoExpanded['Tuesday'] ?? false);
                });
              }),
          SizedBox(height: 12),
          _buildDayCard(width, 'Wednesday', 'You have 8 tasks to complete', 'Not Started', [
            _TaskItem('Team standup', '10:00 AM'),
          ], weights: _dayTextWeights['Wednesday'] ?? const TextWeights(),
              expanded: _todoExpanded['Wednesday'] ?? false,
              onToggle: () {
                setState(() {
                  _todoExpanded['Wednesday'] = !(_todoExpanded['Wednesday'] ?? false);
                });
              }),
        ] else ...[
          _buildJournalEntry(width,
              entry: _journalEntries[0],
              expanded: _journalExpanded[0],
              onToggle: () {
                setState(() {
                  _journalExpanded[0] = !_journalExpanded[0];
                });
              }),
          SizedBox(height: 12),
          _buildJournalEntry(width,
              entry: _journalEntries[1],
              expanded: _journalExpanded[1],
              onToggle: () {
                setState(() {
                  _journalExpanded[1] = !_journalExpanded[1];
                });
              }),
          SizedBox(height: 12),
          _buildJournalEntry(width,
              entry: _journalEntries[2],
              expanded: _journalExpanded[2],
              onToggle: () {
                setState(() {
                  _journalExpanded[2] = !_journalExpanded[2];
                });
              }),
        ]
      ],
    );
  }

  Widget _buildSegmentedToggle(double width) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF5E86FF), Color(0xFFB08BFF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    return Container(
      width: width * 0.28,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        border: Border.all(color: const Color(0xFFE9ECF2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_showTodo) setState(() => _showTodo = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: _showTodo ? gradient : null,
                  color: _showTodo ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/toggle_todolist.png',
                        width: 50,
                        height: 50,
                        color: _showTodo ? Colors.white : Colors.black87,
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_showTodo) setState(() => _showTodo = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: !_showTodo ? gradient : null,
                  color: !_showTodo ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/toggle_journal.png',
                        width: 50,
                        height: 50,
                        color: !_showTodo ? Colors.white : Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalEntry(double width,
      {required _JournalEntry entry, required bool expanded, required VoidCallback onToggle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.emoji, 
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: _journalTextWeights.emoji,
                )
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: TextStyle(
                              fontWeight: _journalTextWeights.title,
                              fontSize: width * 0.045,
                            )
                          ),
                        ),
                        InkWell(
                          onTap: onToggle,
                          child: Icon(
                            expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      entry.dateSubtitle, 
                      style: TextStyle(
                        color: const Color(0xFF94A5AB), 
                        fontWeight: _journalTextWeights.subtitle,
                        fontSize: 13,
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (expanded)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                entry.preview,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: _journalTextWeights.preview,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayCard(double width, String day, String subtitle, String status, List<_TaskItem> tasks, {required TextWeights weights, required bool expanded, required VoidCallback onToggle}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(day, style: TextStyle(fontWeight: weights.title, fontSize: width * 0.045)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: const Color(0xFF6A86F8)),
                    SizedBox(width: 6),
                    Text(status, style: TextStyle(color: const Color(0xFF6A86F8), fontWeight: weights.status)),
                  ],
                ),
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: onToggle,
                child: Icon(
                  expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: const Color(0xFF94A5AB), fontWeight: weights.subtitle)),
          SizedBox(height: 10),
          if (expanded) ...tasks.map((t) => _buildTaskRow(width, t)).toList(),
        ],
      ),
    );
  }

  Widget _buildTaskRow(double width, _TaskItem task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(task.done ? Icons.check_circle : Icons.radio_button_unchecked, color: task.done ? const Color(0xFF6A86F8) : Colors.black26),
          SizedBox(width: 10),
          Expanded(
            child: Text(task.title, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(task.time, style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }

  // Removed _buildCollapsedDay; all days now support expand/collapse inside _buildDayCard

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.home_filled, color: Color(0xFF6A86F8)),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TodoListPage()));
                },
                icon: const Icon(Icons.view_list_outlined, color: Colors.black38),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _upgradeToPremium() async {
    try {
      print('Upgrading to premium...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', true);
      await prefs.setBool('isFirstTime', false); // Mark as not first time
      print('Premium status saved to SharedPreferences');
      print('First time status updated to false');
      
      if (!mounted) {
        print('Widget not mounted, returning');
        return;
      }
      
      setState(() {
        _isPremium = true;
        print('State updated: _isPremium = $_isPremium');
      });
      
      print('Upgrade to premium completed successfully');
    } catch (e) {
      print('Error upgrading to premium: $e');
      // Fallback: update state even if SharedPreferences fails
      if (mounted) {
        setState(() {
          _isPremium = true;
        });
      }
    }
  }

     // Function to show add options popup
   void _showAddOptions(BuildContext context) {
     showDialog(
       context: context,
       barrierColor: Colors.transparent,
       builder: (BuildContext context) {
         return Stack(
           children: [
             Positioned(
               bottom: 100, // Position above FAB
               right: 20,
               child: Container(
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.1),
                       blurRadius: 10,
                       offset: Offset(0, 4),
                     ),
                   ],
                 ),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                                       children: [
                      _buildSimpleAddOption(
                        context,
                        'Add New To-do list',
                        () {
                          Navigator.pop(context);
                          _navigateToTodoList();
                        },
                      ),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                      _buildSimpleAddOption(
                        context,
                        'Add New Journal',
                        () {
                          Navigator.pop(context);
                          _navigateToJournal();
                        },
                      ),
                    ],
                 ),
               ),
             ),
             // Invisible overlay to close popup when tapped outside
             Positioned.fill(
               child: GestureDetector(
                 onTap: () => Navigator.pop(context),
                 child: Container(color: Colors.transparent),
               ),
             ),
           ],
         );
       },
     );
   }

   Widget _buildSimpleAddOption(BuildContext context, String title, VoidCallback onTap) {
     return Material(
       color: Colors.transparent,
       child: InkWell(
         onTap: onTap,
         borderRadius: BorderRadius.circular(12),
         child: Container(
           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
           child: Text(
             title,
             style: TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.w500,
               color: Colors.black87,
             ),
           ),
         ),
       ),
     );
   }

               void _navigateToTodoList() {
       Navigator.push(context, MaterialPageRoute(builder: (context) => TodoListPage()));
     }

    void _navigateToJournal() {
     // TODO: Navigate to Journal page
     print('Navigating to Journal page');
     // Navigator.push(context, MaterialPageRoute(builder: (context) => JournalPage()));
   }

   // Function to reset premium status for testing
   Future<void> _resetPremiumStatus() async {
     try {
       print('Resetting premium status...');
       final prefs = await SharedPreferences.getInstance();
       await prefs.setBool('isPremium', false);
       await prefs.setBool('isFirstTime', true); // Reset to first time
       print('Premium status reset in SharedPreferences');
       print('First time status reset to true');
       
       if (!mounted) {
         print('Widget not mounted, returning');
         return;
       }
       
       setState(() {
         _isPremium = false;
         print('State reset: _isPremium = $_isPremium');
       });
       
       print('Premium status reset completed successfully');
     } catch (e) {
       print('Error resetting premium status: $e');
       if (mounted) {
         setState(() {
           _isPremium = false;
         });
       }
     }
   }
}

class _TaskItem {
  final String title;
  final String time;
  final bool done;

  _TaskItem(this.title, this.time, {this.done = false});
}

class TextWeights {
  final FontWeight title;
  final FontWeight subtitle;
  final FontWeight status;

  const TextWeights({
    this.title = FontWeight.w700,
    this.subtitle = FontWeight.w500,
    this.status = FontWeight.w600,
  });
}

class JournalTextWeights {
  final FontWeight title;
  final FontWeight subtitle;
  final FontWeight preview;
  final FontWeight emoji;

  const JournalTextWeights({
    this.title = FontWeight.w700,
    this.subtitle = FontWeight.w600,
    this.preview = FontWeight.w400,
    this.emoji = FontWeight.w400,
  });
}

class _JournalEntry {
  final String title;
  final String dateSubtitle;
  final String preview;
  final String emoji;

  const _JournalEntry({
    required this.title,
    required this.dateSubtitle,
    required this.preview,
    required this.emoji,
  });
}

class LineChartPainter extends CustomPainter {
  final List<int> data;
  final double maxValue;
  final double maxHeight;
  final Color color;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.maxHeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final segmentWidth = width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * segmentWidth;
      final y = maxHeight - (data[i] / maxValue * maxHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * segmentWidth;
      final y = maxHeight - (data[i] / maxValue * maxHeight);
      canvas.drawCircle(Offset(x, y), 4.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
 

