import 'package:flutter/material.dart';
import 'package:task_tracker/screens/landing_page.dart';
import 'package:task_tracker/screens/task_tracker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      routes: {
        '/': (context) => LandingPage(),
        '/tasktracker': (context) => TaskTracker(),
      },
    );
  }
}
