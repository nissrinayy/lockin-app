import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'services/task_service.dart';
import 'package:firebase_core/firebase_core.dart';

class CreateTaskPage extends StatefulWidget {
  final DateTime? initialDate;
  
  const CreateTaskPage({this.initialDate});
  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  late DateTime _date;
  late TimeOfDay _time;
  bool _submitting = false;
  String _priority = 'none'; // none | low | medium | high
  bool _repeat = false;
  String? _repeatRule; // daily | weekly | monthly
  final List<_SubTask> _subTasks = [];

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    _time = TimeOfDay.fromDateTime(_date);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully.');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection.');
      return false;
    }
    print('Internet connection available.');
    return true;
  }

  Future<void> _create() async {
    if (_title.text.trim().isEmpty) {
      print('Title is empty, cannot create task'); // Debugging log
      return;
    }
    setState(() => _submitting = true);
    final due = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    print('Creating task with due date: $due'); // Debugging log
    try {
      await _initializeFirebase();
      if (!await _checkInternetConnection()) {
        print('Task creation aborted due to no internet connection.');
        return;
      }
      final subPayload = _subTasks
          .where((s) => s.title.trim().isNotEmpty)
          .map((s) => {'title': s.title.trim(), 'completed': s.completed})
          .toList();
      print('Subtasks payload: $subPayload'); // Debugging log
      final taskId = await TaskService.createTask(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        dueDateTime: due,
        priority: _priority,
        repeat: _repeat,
        repeatRule: _repeat ? _repeatRule : null,
        subTasks: subPayload.isEmpty ? null : subPayload,
      );
      print('Task created successfully with ID: $taskId'); // Debugging log
      if (mounted) {
        Navigator.pop(context, due); // Kembalikan DateTime yang digunakan
      }
    } catch (e) {
      print('Error creating task: $e'); // Debugging log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat task: $e')));
      }
    } finally {
      print('Resetting _submitting flag'); // Debugging log
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF6F7FB);
    
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Create New Task', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _inputCard(
                child: TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    hintText: 'Tambahkan Tugas...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _subTaskHeader(),
              const SizedBox(height: 6),
              _subTaskList(),
              const SizedBox(height: 12),
              _inputCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            final base = _title.text.trim().isEmpty ? 'Tugas baru' : _title.text.trim();
                            _desc.text = 'Deskripsi otomatis untuk: $base';
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Auto Write ✨',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _desc,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tambahkan Deskripsi...',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _tile(
                icon: Icons.flag_outlined,
                label: 'Priority',
                value: _priority == 'none' ? 'Tidak' : _priority[0].toUpperCase() + _priority.substring(1),
                active: _priority != 'none',
                onTap: _selectPriority,
              ),
              const SizedBox(height: 8),
              _tile(
                icon: Icons.event,
                label: 'Deadline',
                value: DateFormat('dd/MM/yyyy').format(_date),
                active: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              _tile(
                icon: Icons.access_time,
                label: 'Time',
                value: _time.format(context),
                active: true,
                onTap: _pickTime,
              ),
              const SizedBox(height: 8),
              _tile(
                icon: Icons.autorenew_rounded,
                label: 'Repeat Task',
                value: _repeat ? _prettyRepeatRule() : 'Tidak',
                active: _repeat,
                onTap: _selectRepeat,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(51)),
                          side: BorderSide(color: const Color(0xFF4782F4)),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Color(0xFF4782F4),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _create,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(51),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Create Task',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
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
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      top: false,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_outlined, false, () {
                  Navigator.pushReplacementNamed(context, '/home');
                }),
                _buildNavItem(Icons.list_alt_outlined, true, () {
                  // Current page - do nothing or refresh
                }),
                _buildNavItem(Icons.person_outline, false, () {
                  Navigator.pushNamed(context, '/profile');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFF5C6CF2) : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: child,
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required String value,
    bool active = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            _capsule(value, active),
          ],
        ),
      ),
    );
  }

  Widget _capsule(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: active
            ? const LinearGradient(
                colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: active ? null : const Color(0xFFE9EDFF),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF5C6CF2),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _selectPriority() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => _pickerSheet(
        title: 'Priority',
        options: const ['none', 'low', 'medium', 'high'],
        labels: const ['Tidak', 'Low', 'Medium', 'High'],
        selected: _priority,
      ),
    );
    if (choice != null) setState(() => _priority = choice);
  }

  Future<void> _selectRepeat() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => _pickerSheet(
        title: 'Repeat Task',
        options: const ['none', 'daily', 'weekly', 'monthly'],
        labels: const ['Tidak', 'Daily', 'Weekly', 'Monthly'],
        selected: _repeat ? (_repeatRule ?? 'daily') : 'none',
      ),
    );
    if (choice != null) {
      setState(() {
        if (choice == 'none') {
          _repeat = false;
          _repeatRule = null;
        } else {
          _repeat = true;
          _repeatRule = choice;
        }
      });
    }
  }

  String _prettyRepeatRule() {
    switch (_repeatRule) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return 'Tidak';
    }
  }

  Widget _pickerSheet({
    required String title,
    required List<String> options,
    required List<String> labels,
    required String selected,
  }) {
    String temp = selected;
    
    return SafeArea(
      child: StatefulBuilder(
        builder: (ctx, setSB) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Pilih ${title == 'Priority' ? 'Prioritas' : title}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...List.generate(options.length, (i) {
                final value = options[i];
                final label = labels[i];
                final isSelected = value == temp;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: _leadingFor(title, value),
                    title: Text(label, style: const TextStyle(fontSize: 16)),
                    trailing: _selectionCircle(isSelected),
                    onTap: () => setSB(() => temp = value),
                  ),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9EDFF),
                    foregroundColor: const Color(0xFF5C6CF2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Konfirmasi', style: TextStyle(fontSize: 18)),
                  onPressed: () => Navigator.pop(ctx, temp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subTaskHeader() {
    return Row(
      children: [
        const SizedBox(width: 6),
        const Text('Subtasks', style: TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        IconButton(
          onPressed: () {
            setState(() => _subTasks.add(_SubTask(title: '')));
          },
          icon: const Icon(Icons.add, color: Color(0xFF5C6CF2)),
        )
      ],
    );
  }

  Widget _subTaskList() {
    if (_subTasks.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => setState(() => _subTasks.add(_SubTask(title: ''))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              children: const [
                Icon(Icons.add, size: 18, color: Color(0xFF5C6CF2)),
                SizedBox(width: 6),
                Text(
                  'Tambahkan Tugas Sampingan...',
                  style: TextStyle(
                    color: Color(0xFF5C6CF2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      children: _subTasks.asMap().entries.map((entry) {
        final i = entry.key;
        final sub = entry.value;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => sub.completed = !sub.completed),
                icon: Icon(
                  sub.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: sub.completed ? const Color(0xFF5C6CF2) : Colors.grey,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: sub.controller,
                    onChanged: (v) => sub.title = v,
                    decoration: const InputDecoration(
                      hintText: 'Kerjakan Pilihan Ganda PR MTK',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _subTasks.removeAt(i)),
                icon: const Icon(Icons.close, color: Colors.grey),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _selectionCircle(bool selected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF5C6CF2) : Colors.black26,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            )
          : null,
    );
  }

  Widget _leadingFor(String title, String value) {
    if (title == 'Priority') {
      Color color;
      switch (value) {
        case 'low':
          color = const Color(0xFF4782F4);
          break;
        case 'medium':
          color = const Color(0xFFFFA726);
          break;
        case 'high':
          color = const Color(0xFFE53935);
          break;
        default:
          color = Colors.grey;
      }
      return Icon(Icons.flag, color: color);
    }
    return const Icon(Icons.autorenew_rounded, color: Color(0xFF5C6CF2));
  }
}

class _SubTask {
  String title;
  bool completed;
  final TextEditingController controller;

  _SubTask({required this.title, this.completed = false})
      : controller = TextEditingController(text: title);
}