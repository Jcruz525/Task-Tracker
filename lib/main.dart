import 'package:flutter/material.dart';
import 'package:task_tracker/screens/landing_page.dart';
import 'package:task_tracker/screens/task_tracker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'package:task_tracker/screens/calendar_screen.dart';
import 'package:task_tracker/task_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ToDoApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child); 
      },
      routes: [
        GoRoute(
          path: '/tasktracker',
          builder: (context, state) => const TaskTracker(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        
      ],
    ),
  ],
);

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}
class _MainScaffoldState extends State<MainScaffold> {
  final int _currentIndex = 0;
  final TaskStorage storage = TaskStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _todayDay;
  late String userId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDay = now.day.toString();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  void _onTap(int index) async {
    if (index == 2) {
      final result = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.indigoAccent[700],
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const AddTaskBottomSheet(),
      );
      if (result != null) {
        await _firestore.collection('users').doc(userId).collection('tasks').add(result);
      }
    } else if (index == 1) {
      context.go('/calendar');
    }
    else if (index == 0) {
      context.go('/tasktracker');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple[50],
        unselectedItemColor: Colors.purple[50],
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTap,
        backgroundColor: Colors.indigoAccent[700],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.calendar_today, size: 30, color: Colors.white),
                Positioned(
                  top: 4.5,
                  right: 3.5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Text(
                      _todayDay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[50],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            label: 'Today',
          ),
          const BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(
              Icons.today,
              size: 30,
              color: Color.fromARGB(255, 243, 229, 245),
            ),
            label: 'Calendar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              size: 30,
              color: Color.fromARGB(255, 243, 229, 245),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: Color.fromARGB(255, 243, 229, 245),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

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
