import 'package:flutter/material.dart';
import 'package:task_tracker/screens/landing_page.dart';
import 'package:task_tracker/screens/task_tracker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'package:task_tracker/screens/calendar_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/task_bloc.dart';
import 'bloc/task_event.dart';
import 'bloc/auth_cubit.dart';
import 'widgets/add_task_modal.dart';
import 'models/task.dart';
import 'package:task_tracker/screens/search.dart';
import 'repositories/user_repositories.dart';
import 'screens/profile_page.dart';
import 'bloc/user_Profiles/profile_bloc.dart';
import 'bloc/user_Profiles/profile_event.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(FirebaseAuth.instance),
      child: const ToDoApp(),
    ),
  );
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
        
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchPage(),
        ),
       GoRoute(
  path: '/settings',
  builder: (context, state) {
    return BlocProvider(
      create: (_) => ProfileBloc(UserRepository())..add(LoadProfile()),
      child: const ProfilePage(),
    );
  },
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
   int currentIndex = 0;

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
      builder: (context) => const AddTaskModal(),
    );

    if (result != null && result is Map<String, dynamic>) {
      final task = Task(
        id: '',
        title: result['title'],
        priority: result['priority'] ?? 'Medium',
        dueDate: result['dueDate'] is DateTime ? result['dueDate'] : null,
        recurring: result['recurring'] ?? false,
        done: false,
        createdAt: DateTime.now(),
      );

      context.read<TaskBloc>().add(AddTask(task));
    }
  } else if (index == 1) {
    context.go('/calendar');
  } else if (index == 0) {
    context.go('/tasktracker');
  }
  else if (index == 3) {
    context.go('/search');
  } else if (index == 4) {
    context.go('/settings'); 
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
        currentIndex: currentIndex,
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
                    width: 22,
                    alignment: Alignment.center,
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (authState.user == null) {
          return MaterialApp(
            home: LandingPage(),
          );
        }

        return BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            firestore: FirebaseFirestore.instance,
            userId: authState.user!.uid,
          )..add(LoadTasks()),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
          ),
        );
      },
    );
  }
}
