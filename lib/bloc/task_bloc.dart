import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_event.dart';
import 'task_state.dart';
import '../../models/task.dart';
import 'dart:async';


class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseFirestore firestore;
  final String userId;
  StreamSubscription? _tasksSubscription;

  TaskBloc({required this.firestore, required this.userId}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<_TasksUpdated>(_onTasksUpdated);
    on<QuickAddTask>(_onQuickAddTask);
  }

  CollectionReference get _taskCollection =>
      firestore.collection('users').doc(userId).collection('tasks');

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());

   
    await _tasksSubscription?.cancel();

    _tasksSubscription = _taskCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final tasks = snapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
      add(_TasksUpdated(tasks));
    }, onError: (error) {
      emit(TaskError('Failed to load tasks: $error'));
    });
  }
  Future<void> _onQuickAddTask(QuickAddTask event, Emitter<TaskState> emit) async {
  try {
    final newTask = Task(
      id: '', 
      title: event.title,
      priority: 'Medium', 
      dueDate: DateTime.now(), 
      recurring: false,
      done: false,
      createdAt: DateTime.now(),
    );
    await _taskCollection.add(newTask.toMap());
  } catch (e) {
    emit(TaskError('Failed to quick add task: $e'));
  }
}

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _taskCollection.add(event.task.toMap());
    } catch (e) {
      emit(TaskError('Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _taskCollection.doc(event.task.id).update(event.task.toMap());
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _taskCollection.doc(event.taskId).delete();
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }

 
  void _onTasksUpdated(_TasksUpdated event, Emitter<TaskState> emit) {
    emit(TaskLoaded(event.tasks));
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}


class _TasksUpdated extends TaskEvent {
  final List<Task> tasks;
  _TasksUpdated(this.tasks);
}
