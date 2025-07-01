class TaskStorage {
  // Singleton pattern
  static final TaskStorage _instance = TaskStorage._internal();

  factory TaskStorage() {
    return _instance;
  }

  TaskStorage._internal();

  final List<Map<String, dynamic>> tasks = [];
}
