import 'package:flutter/material.dart';
import 'package:task_tracker/cubits/task_cubit/task_cubit.dart';
import 'package:task_tracker/screens/login/signup.dart';
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
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(FirebaseAuth.instance),
        ),
        BlocProvider(create: (context) => TaskCubit()),
      ],
      child: const ToDoApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
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
    print("Today is: $_todayDay");
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  void _onTap(int index) async {
    //context.read<TaskCubit>().getTasks(userId);
    //print('Johnny : ${context.read<TaskCubit>().state.tasks}');
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
      if (!mounted) return;
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
    } else if (index == 3) {
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
            icon: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 30,
                    color: Colors.white,
                  ),

                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _todayDay,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
          return MaterialApp(home: LandingPage());
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
