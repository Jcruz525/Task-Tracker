import 'package:flutter/material.dart';
import 'package:task_tracker/pages/landing_page.dart';
import 'package:task_tracker/pages/task_tracker.dart';

void main() => runApp(ToDoApp());

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
