import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tracker/bloc/task_bloc.dart';
import 'package:task_tracker/bloc/task_state.dart';
import 'package:task_tracker/models/task.dart';
import 'package:task_tracker/bloc/task_event.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  DateTime? _selectedDate;
  String _selectedPriority = 'All';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      final matchesDate = _selectedDate == null
          ? true
          : (task.dueDate != null &&
              task.dueDate!.year == _selectedDate!.year &&
              task.dueDate!.month == _selectedDate!.month &&
              task.dueDate!.day == _selectedDate!.day);

      final matchesPriority =
          _selectedPriority == 'All' ? true : task.priority == _selectedPriority;

      return matchesDate && matchesPriority;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Search Tasks',style: TextStyle(color: Colors.purple[50]!,fontWeight: FontWeight.bold,
              letterSpacing: .5,)),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent[700],
      ),
      backgroundColor: Colors.purple[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.indigoAccent[700]!)),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Filter by Due Date'
                            : 'Due: ${DateFormat.yMMMd().format(_selectedDate!)}',
                        style: TextStyle(
                          color: Colors.indigoAccent[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.red[400]),
                    onPressed: _clearDate,
                  ),
              ],
            ),

            const SizedBox(height: 16),

          
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Filter by Priority',
                labelStyle: TextStyle(color: Colors.indigoAccent[700], fontSize: 20),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigoAccent[700]!),
                ),
              ),
              items: ['All', 'High', 'Medium', 'Low']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPriority = val;
                  });
                }
              },
              dropdownColor: Colors.indigoAccent[700],
              style: TextStyle(color: Colors.purple[50]),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TaskLoaded) {
                    final filteredTasks = _filterTasks(state.tasks);
                    if (filteredTasks.isEmpty) {
                      return const Center(child: Text('No tasks found'));
                    }
                    return ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: Colors.indigoAccent[700],
                          child: ListTile(
                            title: Text(
                              task.title,
                              style: TextStyle(
                                color: Colors.purple[50],
                                decoration: task.done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              'Priority: ${task.priority}${task.dueDate != null ? ', Due: ${DateFormat.yMMMd().format(task.dueDate!)}' : ''}',
  style: TextStyle(color: Colors.purple[100]),
                            ),
                            trailing: Checkbox(
                              value: task.done,
                              onChanged: (val) {
                                context
                                    .read<TaskBloc>()
                                    .add(UpdateTask(task.copyWith(done: val)));
                              },
                              checkColor: Colors.purple[50],
                              activeColor: Colors.green,
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is TaskError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('No tasks available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
