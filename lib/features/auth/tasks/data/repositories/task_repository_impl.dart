import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../../data/domain/entities/task.dart';

class TaskRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // 1. Fetch Tasks (Real-time)
  Stream<List<Task>> getTasks() {
    if (_userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 2. Add Task
  Future<void> addTask(TaskModel task) async {
    if (_userId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .add(task.toMap());
  }

  // 3. Update Task (For Editing)
  Future<void> updateTask(String taskId, TaskModel task) async {
    if (_userId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .update(task.toMap());
  }

  // 4. Toggle Status
  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    if (_userId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': isCompleted});
  }

  // 5. Delete Task (This fixes your current error)
  Future<void> deleteTask(String taskId) async {
    if (_userId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
