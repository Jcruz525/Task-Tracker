// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTaskModal extends StatefulWidget {
  const AddTaskModal({super.key});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskController = TextEditingController();
  String _priority = 'Medium';
  DateTime? _dueDate = DateTime.now();
  bool _isRecurring = false;

  void _submitTask() async {
  if (_formKey.currentState!.validate()) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final newTask = {
      'title': _taskController.text,
      'priority': _priority,
      'dueDate': _dueDate != null ? Timestamp.fromDate(_dueDate!) : null,
      'recurring': _isRecurring,
      'done': false,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .add(newTask);
      if (!mounted) return;
      Navigator.pop(context); 
    } catch (e) {
      print('Error adding task: $e');
    }
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
              const SizedBox(height: 12),
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
                 'Due: ${DateFormat.yMMMd().format(_dueDate!)}',
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
                activeColor: Colors.purple[50],
                activeTrackColor: Colors.green[600],
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
