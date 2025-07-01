
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  Stream<List<Task>> getTasks() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> addTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .add(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
