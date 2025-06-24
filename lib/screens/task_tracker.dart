import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class TaskTracker extends StatefulWidget {
  const TaskTracker({super.key});
  @override
  TaskTrackerState createState() => TaskTrackerState();
}

class TaskTrackerState extends State<TaskTracker> {
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController controller = TextEditingController();
  final List<String> commonTasks = [
    "Buy groceries",
    "Do laundry",
    "Call mom",
    "Pay bills",
    "Clean kitchen",
    "Workout",
    "Walk dog",
    "Reply emails",
    "Study",
    "Meditate",
  ];
  final List<String> taskLabels = [
    "Groceries",
    "Laundry",
    "Call",
    "Bills",
    "Kitchen",
    "Workout",
    "Walk",
    "Emails",
    "Study",
    "Calm",
  ];

  void addTask(String task) {
    if (task.isEmpty) return;
    setState(() {
      tasks.add({'title': task, 'done': false});
    });
    controller.clear();
  }

  void quickAdd(dynamic task) {
    setState(() {
      tasks.add({'title': task, 'done': false});
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index]['done'] = !tasks[index]['done'];
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void editTask(int index) {
    final TextEditingController editTaskController = TextEditingController(
      text: tasks[index]['title'],
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit this task!"),
          content: TextField(controller: editTaskController),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  tasks[index]['title'] = editTaskController.text;
                  Navigator.pop(context);
                });
              },
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Exit"),
            ),
          ],
        );
      },
    );
  }

  String _todayDay = '';

  @override
  void initState() {
    super.initState();
    _updateTodayDate();
  }

  void _updateTodayDate() {
    final now = DateTime.now();
    final dayNumber = DateFormat('d').format(now);
    setState(() {
      _todayDay = dayNumber;
    });
  }

  void _onBottomNavTap(int index) async {
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
        setState(() {
          tasks.add(result);
        });
      }
    } else if (index == 1) {
      context.go('/calendar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color.fromARGB(255, 243, 229, 245),
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          'Task Tracker',
          style: TextStyle(
            color: Colors.purple[50],
            fontWeight: FontWeight.bold,
            letterSpacing: .5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent[700],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple[50],
        unselectedItemColor: Colors.purple[50],
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: _onBottomNavTap,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.calendar_today, size: 30, color: Colors.white),
                Positioned(
                  top: 4.5,
                  right: 3.5,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.transparent),
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
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(
              Icons.today,
              size: 30,
              color: Color.fromARGB(255, 243, 229, 245),
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              size: 30,
              color: Color.fromARGB(255, 243, 229, 245),
            ),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: Color.fromARGB(255, 243, 229, 245),
            ),
            label: 'Settings',
          ),
        ],
        backgroundColor: Colors.indigoAccent[700],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: commonTasks.length,
              itemBuilder: (context, index) {
                final fullTask = commonTasks[index];
                final shortLabel = taskLabels[index];
                return Container(
                  width: 140,
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  child: Card(
                    color: Colors.indigoAccent[700],
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Text(
                              textAlign: TextAlign.center,
                              shortLabel,
                              style: TextStyle(
                                color: Colors.purple[50],
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Center(
                            child: IconButton(
                              icon: Icon(Icons.add),
                              iconSize: 25,
                              color: Colors.purple[50],
                              onPressed: () => quickAdd(fullTask),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 25),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Colors.indigoAccent[700],
                  child: ListTile(
                    leading: Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          side: BorderSide(color: Colors.purple[50]!, width: 2),
                        ),
                      ),
                      child: Checkbox(
                        value: task['done'],
                        onChanged: (value) => toggleTask(index),
                        checkColor: Colors.purple[50],
                        activeColor: Colors.green,
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.green;
                          }
                          return Colors.purple.shade50;
                        }),
                      ),
                    ),

                    title: Text(
                      task['title'],
                      style: TextStyle(
                        decoration: task['done']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationThickness: 4.0,
                        color: Colors.purple[50],
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.purple[50]),
                          onPressed: () => deleteTask(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.purple[50]),
                          onPressed: () => editTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key});
  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskController = TextEditingController();
  String _priority = 'Medium';
  DateTime? _dueDate;
  bool _isRecurring = false;

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = {
        'title': _taskController.text,
        'priority': _priority,
        'dueDate': _dueDate,
        'recurring': _isRecurring,
        'done': false,
      };
      Navigator.pop(context, newTask);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                cursorColor: Colors.purple[50],
                style: TextStyle(color: Colors.purple[50]),
                controller: _taskController,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[50]!, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[50]!, width: 2),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 3),
                  ),
                  labelText: 'Task Title',
                  labelStyle: TextStyle(color: Colors.purple[50]),
                ),
                validator: (value) => value!.isEmpty ? 'Enter a task' : null,
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                style: TextStyle(
                  color: Colors.purple[50]!,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.indigoAccent[700],
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[50]!, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[50]!, width: 2),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 3),
                  ),
                  labelText: 'Priority',
                  labelStyle: TextStyle(color: Colors.purple[50]),
                ),
                items: ['High', 'Medium', 'Low']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              ListTile(
                title: Text(
                  _dueDate == null
                      ? 'Pick a due date'
                      : 'Due: ${DateFormat.yMMMd().format(_dueDate!)}',
                  style: TextStyle(color: Colors.purple[50]),
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.purple[50]),
                onTap: _pickDate,
              ),
              SwitchListTile(
                title: Text(
                  'Recurring Task',
                  style: TextStyle(color: Colors.purple[50]),
                ),
                value: _isRecurring,
                onChanged: (val) => setState(() => _isRecurring = val),
                activeColor: Colors.purple[50], //
                activeTrackColor: Colors.green[500],
                inactiveThumbColor: Colors.purple[50],
                inactiveTrackColor: Colors.grey[700],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitTask,
                child: Text(
                  'Add Task',
                  style: TextStyle(color: Colors.indigoAccent[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
