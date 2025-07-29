
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_tracker/client/firebase_client.dart';
import '../models/task.dart';


class TaskService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final FirebaseClient client;

  String get _userId => _auth.currentUser!.uid;

  TaskService({FirebaseClient? client}): client = client ?? FirebaseClient();

  
  // //Stream<List<Task>> getTasks() {
  //   return _firestore
  //       .collection('users')
  //       .doc(_userId)
  //       .collection('tasks')
  //       .snapshots()
  //       .map((snapshot) =>
  //           snapshot.docs.map((doc) => Task.fromMap(doc.id, doc.data())).toList());
  // }

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

  Future<List<Task>> getTasks({required String userId}) async {
  final tasksData = await client.getSubCollection(
    parentCollection: 'users',
    parentDocId: userId,
    subCollection: 'tasks',
  );
  return tasksData.map((data) => Task.fromMap(data['id'], data)).toList();
}
}

