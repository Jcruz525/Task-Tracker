import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.purple[50]),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

          Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'Enter task'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => addTask(controller.text),
                ),
              ],
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
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.purple[50]),
                      onPressed: () => deleteTask(index),
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
