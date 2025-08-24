import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/task_service.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool _showTodo = true; // true = To-do list, false = Journal
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<Map<String, dynamic>> _remoteTasks = [];
  bool _loadingTasks = false;
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loadingTasks = true);
    try {
      print('Loading tasks for date: $_selectedDate'); // Debug log
      final tasks = await TaskService.fetchTasksForDate(_selectedDate);
      if (mounted) {
        setState(() {
          _remoteTasks = tasks;
          print('Loaded ${tasks.length} tasks'); // Debug log
        });
      }
    } catch (e) {
      print('Error loading tasks: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingTasks = false);
    }
  }

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm WIB';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // Main Navigation Tabs
            _buildNavigationTabs(width),
            
            // Date Navigation
            _buildDateNavigation(width),
            
            // Task Summary
            _buildTaskSummary(width),
            
            // Task List
            Expanded(
              child: _buildTaskList(width),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/create-task', arguments: _selectedDate);
            if (result != null) {
              _loadTasks();
            }
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildNavigationTabs(double width) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _showTodo = true);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: _showTodo ? LinearGradient(
                      colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ) : null,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist,
                        color: _showTodo ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'To do list',
                        style: TextStyle(
                          color: _showTodo ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _showTodo = false);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: !_showTodo ? LinearGradient(
                      colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ) : null,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book,
                        color: !_showTodo ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Journal',
                        style: TextStyle(
                          color: !_showTodo ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigation(double width) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Column(
        children: [
          // Month and year display with navigation
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                  });
                },
                icon: Icon(Icons.arrow_back_ios, size: 20),
              ),
              Expanded(
                child: Text(
                  '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                  });
                },
                icon: Icon(Icons.arrow_forward_ios, size: 20),
              ),
              GestureDetector(
                onTap: () {
                  _showDatePicker();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Select Date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Calendar week view
          _buildCalendarWeekView(width),
        ],
      ),
    );
  }

  Widget _buildCalendarWeekView(double width) {
    // Get the week containing the selected date
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    
    return Container(
      child: Column(
        children: [
          // Days of week headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 8),
          // Week dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((date) {
              final isSelected = date.day == _selectedDate.day && 
                               date.month == _selectedDate.month &&
                               date.year == _selectedDate.year;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  _loadTasks();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isSelected ? LinearGradient(
                      colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ) : null,
                    color: !isSelected ? Colors.grey[100] : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSummary(double width) {
    final completedTasks = _remoteTasks.where((task) => task['completed'] == true).length;
    final totalTasks = _remoteTasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF6A86F8).withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today, you still have ${totalTasks - completedTasks} task left',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6A86F8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(double width) {
    if (_loadingTasks) {
      return Center(child: CircularProgressIndicator());
    }

    if (_remoteTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No tasks for this date',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 16),
      child: ListView.builder(
        itemCount: _remoteTasks.length,
        itemBuilder: (context, index) {
          final task = _remoteTasks[index];
          
          // Ensure task data is not null or empty
          final title = task['title'] ?? 'Untitled Task';
          final description = task['description']?.isNotEmpty == true ? task['description'] : 'No description provided';
          final time = task['time'] ?? '00:00 WIB';
          final subTasksCompleted = task['subTasksCompleted'] ?? 0;
          final totalSubTasks = task['totalSubTasks'] ?? 1;
          final completed = task['completed'] ?? false;

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // Left side with circle and dotted line
                Column(
                  children: [
                    // Task status circle
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: completed
                            ? LinearGradient(
                                colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: !completed ? Colors.grey[300] : null,
                        shape: BoxShape.circle,
                      ),
                      child: completed
                          ? Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                    // Dotted line (except for last item)
                    if (index != _remoteTasks.length - 1)
                      Container(
                        width: 2,
                        height: 40,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        color: Colors.grey[300],
                      ),
                  ],
                ),
                SizedBox(width: 12),
                // Task details
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '$subTasksCompleted/$totalSubTasks',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // More options
                        IconButton(
                          onPressed: () {
                            // TODO: Show task options
                          },
                          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.home_filled, color: Colors.black38),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.view_list_outlined, color: Color(0xFF6A86F8)),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with month navigation
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                        });
                        Navigator.pop(context);
                        _showDatePicker();
                      },
                      icon: Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                        });
                        Navigator.pop(context);
                        _showDatePicker();
                      },
                      icon: Icon(Icons.arrow_forward_ios, size: 20),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Days of week
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map((day) => Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 8),
                
                // Calendar grid
                Container(
                  height: 240,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 42,
                    itemBuilder: (context, index) {
                      final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
                      final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
                      final firstWeekday = firstDayOfMonth.weekday;
                      final dayOffset = index - (firstWeekday - 1);
                      final day = dayOffset + 1;
                      
                      if (dayOffset < 0 || day > daysInMonth) {
                        return Container(); // Empty space
                      }
                      
                      final isSelected = day == _selectedDate.day && 
                                       _currentMonth.month == _selectedDate.month &&
                                       _currentMonth.year == _selectedDate.year;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, day);
                          });
                          Navigator.pop(context);
                          _loadTasks();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isSelected ? LinearGradient(
                              colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ) : null,
                            color: !isSelected ? Colors.grey[100] : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 8),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: const Color(0xFF6A86F8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Pilih',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Januari';
      case 2: return 'Februari';
      case 3: return 'Maret';
      case 4: return 'April';
      case 5: return 'Mei';
      case 6: return 'Juni';
      case 7: return 'Juli';
      case 8: return 'Agustus';
      case 9: return 'September';
      case 10: return 'Oktober';
      case 11: return 'November';
      case 12: return 'Desember';
      default: return '';
    }
  }
}

class TaskItem {
  final String title;
  final String time;
  final bool completed;
  final int subTasksCompleted;
  final int totalSubTasks;

  TaskItem({
    required this.title,
    required this.time,
    required this.completed,
    required this.subTasksCompleted,
    required this.totalSubTasks,
  });
}