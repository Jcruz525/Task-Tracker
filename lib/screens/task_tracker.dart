import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskTracker extends StatefulWidget {
  const TaskTracker({super.key});
  @override
  TaskTrackerState createState() => TaskTrackerState();
}

class TaskTrackerState extends State<TaskTracker> {
  final TextEditingController controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

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

  void addTask(String task) async {
    if (task.isEmpty) return;
    await _firestore.collection('users').doc(userId).collection('tasks').add({
      'title': task,
      'done': false,
      'createdAt': Timestamp.now(),
    });
    controller.clear();
  }

  void quickAdd(String task) async {
    await _firestore.collection('users').doc(userId).collection('tasks').add({
      'title': task,
      'done': false,
      'createdAt': Timestamp.now(),
    });
  }

  String _todayDay = '';

  @override
  void initState() {
    super.initState();
    _updateTodayDate();
    _firestore.collection('users').doc(userId).collection('tasks').add({
    'title': 'Test Task',
    'done': false,
    'createdAt': Timestamp.now(),
  });
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
        await _firestore.collection('users').doc(userId).collection('tasks').add(result);
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('tasks')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                print('Has data: ${snapshot.hasData}');
  if (snapshot.hasError) print('Error: ${snapshot.error}');
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
  
                final taskDocs = snapshot.data!.docs;
print('Fetched tasks:');
for (var doc in taskDocs) {
  print(' - ${doc.data()}');
}

                return ListView.builder(
                  itemCount: taskDocs.length,
                  itemBuilder: (context, index) {
                    final doc = taskDocs[index];
                    final task = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: Colors.indigoAccent[700],
                      child: ListTile(
                        leading: Checkbox(
                          value: task['done'],
                          onChanged: (value) {
                            _firestore
                                .collection('users')
                                .doc(userId)
                                .collection('tasks')
                                .doc(doc.id)
                                .update({'done': value});
                          },
                          checkColor: Colors.purple[50],
                          activeColor: Colors.green,
                        ),
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            decoration: task['done']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: Colors.purple[50],
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.purple[50]),
                          onPressed: () {
                            _firestore
                                .collection('users')
                                .doc(userId)
                                .collection('tasks')
                                .doc(doc.id)
                                .delete();
                          },
                        ),
                      ),
                    );
                  },
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
        'createdAt': Timestamp.now(),
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
                  labelText: 'Task Title',
                  labelStyle: TextStyle(color: Colors.purple[50]),
                ),
                validator: (value) => value!.isEmpty ? 'Enter a task' : null,
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                style: TextStyle(color: Colors.purple[50]),
                dropdownColor: Colors.indigoAccent[700],
                decoration: InputDecoration(
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