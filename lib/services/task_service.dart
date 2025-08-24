import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String _ymd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  static Future<User> _ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  static Future<String> createTask({
    required String title,
    String? description,
    required DateTime dueDateTime,
    String priority = 'none',
    bool repeat = false,
    String? repeatRule,
    List<Map<String, dynamic>>? subTasks,
  }) async {
    final uid = (await _ensureSignedIn()).uid;
    print('Creating task for user: $uid'); // Debugging log
    final total = (subTasks?.length ?? 0);
    final completed = (subTasks == null)
        ? 0
        : subTasks.where((s) => (s['completed'] ?? false) == true).length;

    final taskData = {
      'title': title,
      'description': description ?? '',
      'priority': priority,
      'repeat': repeat,
      if (repeatRule != null) 'repeatRule': repeatRule,
      if (subTasks != null) 'subTasks': subTasks,
      'completed': false,
      'dueAt': Timestamp.fromDate(dueDateTime),
      'dueYmd': _ymd(dueDateTime),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'subTasksCompleted': completed,
      'totalSubTasks': total == 0 ? 1 : total,
    };
    print('Task data to be sent: $taskData'); // Debugging log

    int retries = 3;
    while (retries > 0) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .add(taskData);
        print('Task created successfully with ID: ${doc.id}'); // Debugging log
        return doc.id;
      } catch (e) {
        print('Error creating task: $e'); // Debugging log
        retries--;
        if (retries == 0) {
          throw Exception('Failed to create task after multiple attempts: $e');
        }
        print('Retrying task creation... ($retries retries left)');
        await Future.delayed(Duration(seconds: 2)); // Wait before retrying
      }
    }
    throw Exception('Unexpected error during task creation');
  }

  static Future<List<Map<String, dynamic>>> fetchTasksForDate(DateTime date) async {
    final uid = (await _ensureSignedIn()).uid;
    final ymd = _ymd(date);
    
    print('Fetching tasks for UID: $uid, Date: $ymd'); // Debug log
    
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('dueYmd', isEqualTo: ymd)
        .orderBy('dueAt')
        .get();

    final tasks = snap.docs.map((d) => {
      'id': d.id, 
      ...d.data(),
      'time': _formatTime((d.data()['dueAt'] as Timestamp).toDate()),
    }).toList();
    
    print('Found ${tasks.length} tasks for date $ymd'); // Debug log
    for (var task in tasks) {
      print('Task: ${task['title']} - ${task['dueYmd']}'); // Debug log
    }
    
    return tasks;
  }

  static String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm WIB';
  }

  static Stream<List<Map<String, dynamic>>> getTasksStream(DateTime date) async* {
    final uid = (await _ensureSignedIn()).uid;
    final ymd = _ymd(date);
    
    print('Creating stream for UID: $uid, Date: $ymd'); // Debug log
    
    yield* _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('dueYmd', isEqualTo: ymd)
        .orderBy('dueAt')
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
            'time': _formatTime((doc.data()['dueAt'] as Timestamp).toDate()),
          }).toList();
          
          print('Stream received ${tasks.length} tasks for date $ymd'); // Debug log
          return tasks;
        });
  }
}