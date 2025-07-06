import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tracker/bloc/task_bloc.dart';
import 'package:task_tracker/bloc/task_event.dart';
import 'package:task_tracker/bloc/task_state.dart';
import 'package:task_tracker/models/task.dart';


class TaskTracker extends StatefulWidget {
  const TaskTracker({super.key});
  @override
  TaskTrackerState createState() => TaskTrackerState();
}

class TaskTrackerState extends State<TaskTracker> {
  final TextEditingController controller = TextEditingController();
Widget _buildTaskTile(Task task) {
  return TaskTileEditor(task: task);
}

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
  final newTask = Task(
    id: '', 
    title: task,
    priority: 'Medium',
    dueDate: null,
    recurring: false,
    done: false,
    createdAt: DateTime.now(),
  );
  context.read<TaskBloc>().add(AddTask(newTask));
  controller.clear();
}

void quickAdd(String task) {
  if (task.isEmpty) return;
  context.read<TaskBloc>().add(QuickAddTask(task));
}



    String _todayDay = '';

    @override
    void initState() {
      super.initState();
      _updateTodayDate();
    }

    void _updateTodayDate() {
      final now = DateTime.now();
      final dayNumber = DateFormat('MMMM d, y').format(now);

      setState(() {
        _todayDay = dayNumber;
      });
    }




    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.purple[50],
        appBar: AppBar(

          title: Text(
            _todayDay,
            style: TextStyle(
              color: Colors.purple[50],
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
          ),
          centerTitle: true,
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
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            final tasks = state.tasks;

            if (tasks.isEmpty) {
              return const Center(child: Text('No tasks available.'));
            }

            final today = DateTime.now();

bool isSameDay(DateTime? date1, DateTime date2) {
  if (date1 == null) return false;
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

final todayTasks = tasks.where((task) {
  return isSameDay(task.dueDate, today);
}).toList();

final toDoTasks = todayTasks.where((task) => !task.done).toList();
final completedTasks = todayTasks.where((task) => task.done).toList();


            return
              Theme(
  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
  child: ListView(
    children: [
      if (toDoTasks.isNotEmpty)
        ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            'To Do (${toDoTasks.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.indigoAccent[700],
            ),
          ),
          children: toDoTasks.map(_buildTaskTile).toList(),
        ),
      if (completedTasks.isNotEmpty)
        ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            'Completed (${completedTasks.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.green[700],
            ),
          ),
          children: completedTasks.map(_buildTaskTile).toList(),
        ),
    ],
  ),
);
          } else if (state is TaskError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('Unknown state'));
          }
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
      'createdAt': DateTime.now(), 
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
                    borderSide: BorderSide(color: Colors.purple[50]!, width: 2.5),
                  ),
                  labelText: 'Task Title',
                  labelStyle: TextStyle(color: Colors.purple[50]),
                ),
                validator: (value) => value!.isEmpty ? 'Enter a task' : null,
              ),
              DropdownButtonFormField<String>(
                iconEnabledColor: Colors.purple[50], 
  iconDisabledColor: Colors.purple[50],
                value: _priority,
                style: TextStyle(color: Colors.purple[50]),
                dropdownColor: Colors.indigoAccent[700],
                decoration: InputDecoration(
                  labelText: 'Priority',
                  labelStyle: TextStyle(color: Colors.purple[50]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[50]!, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[50]!, width: 2.5),
                  ),
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
                title: Text('Recurring Task', style: TextStyle(color: Colors.purple[50])),
                value: _isRecurring,
                onChanged: (val) => setState(() => _isRecurring = val),
                activeColor: Colors.purple[50],
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
class TaskTileEditor extends StatefulWidget {
  final Task task;

  const TaskTileEditor({super.key, required this.task});

  @override
  State<TaskTileEditor> createState() => _TaskTileEditorState();
}

class _TaskTileEditorState extends State<TaskTileEditor> {
  late bool isExpanded;
  late TextEditingController titleController;
  late String priority;
  DateTime? dueDate;
  late bool isRecurring;

  @override
  void initState() {
    super.initState();
    isExpanded = false;
    titleController = TextEditingController(text: widget.task.title);
    priority = widget.task.priority;
    dueDate = widget.task.dueDate;
    isRecurring = widget.task.recurring;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => dueDate = picked);
  }

  void _saveChanges() {
    final updatedTask = widget.task.copyWith(
      title: titleController.text,
      priority: priority,
      dueDate: dueDate,
      recurring: isRecurring,
    );
    context.read<TaskBloc>().add(UpdateTask(updatedTask));
    setState(() => isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      color: Colors.indigoAccent[700],
      child: Column(
        children: [
          ListTile(
            leading: Checkbox(
              value: widget.task.done,
              onChanged: (value) {
                context.read<TaskBloc>().add(UpdateTask(widget.task.copyWith(done: value)));
              },
              checkColor: Colors.purple[50],
              activeColor: Colors.green,
              side: BorderSide(color: Colors.purple[50]!, width: 2),
            ),
            title: Text(
              widget.task.title,
              style: TextStyle(
                decoration: widget.task.done ? TextDecoration.lineThrough : TextDecoration.none,
                color: Colors.purple[50],
                fontWeight: FontWeight.w500,
                fontSize: 17,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.purple[50]),
                  onPressed: () => setState(() => isExpanded = !isExpanded),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.purple[50]),
                  onPressed: () => context.read<TaskBloc>().add(DeleteTask(widget.task.id)),
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    style: TextStyle(color: Colors.purple[50]),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: Colors.purple[50]),
                      
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: priority,
                    dropdownColor: Colors.indigoAccent[700],
                    style: TextStyle(color: Colors.purple[50]),
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(color: Colors.purple[50]),
                    ),
                    items: ['High', 'Medium', 'Low']
                        .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                        .toList(),
                    onChanged: (val) => setState(() => priority = val!),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(
                      dueDate == null
                          ? 'No due date'
                          : 'Due: ${DateFormat.yMMMd().format(dueDate!)}',
                      style: TextStyle(color: Colors.purple[50]),
                    ),
                    trailing: Icon(Icons.calendar_today, color: Colors.purple[50]),
                    onTap: _pickDate,
                  ),
                  SwitchListTile(
                    title: Text('Recurring', style: TextStyle(color: Colors.purple[50])),
                    value: isRecurring,
                    onChanged: (val) => setState(() => isRecurring = val),
                    activeColor: Colors.purple[50],
                  ),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text('Save', style: TextStyle(color: Colors.indigoAccent[700])),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
