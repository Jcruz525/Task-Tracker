import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_tracker/models/task.dart';
import 'package:task_tracker/services/task_service.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskService taskService;
  TaskCubit({TaskService? taskService})
    : taskService = taskService ?? TaskService(),
      super(TaskInitial());

  Future<void> getTasks(String userId) async {
    List<Task> tasks = await taskService.getTasks(userId: userId);
    emit(state.copyWith(tasks: tasks));
  }
}
