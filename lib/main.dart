import 'package:flutter/material.dart';
import 'package:task_tracker/screens/landing_page.dart';
import 'package:task_tracker/screens/task_tracker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'package:task_tracker/screens/calendarScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ToDoApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(
      path: '/tasktracker',
      builder: (context, state) => const TaskTracker(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarPage(),
    ),
  ],
);

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      routerConfig: _router,
    );
  }
}
