import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_state.dart';
import '../models/task.dart';
import '../bloc/task_event.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Map<DateTime, List<Task>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _events = {};
    context.read<TaskBloc>().add(LoadTasks());
  }

  
  DateTime _stripTime(DateTime date) => DateTime(date.year, date.month, date.day);

  List<Task> _getEventsForDay(DateTime day) => _events[_stripTime(day)] ?? [];

  
  void _groupTasksByDate(List<Task> tasks) {
    final Map<DateTime, List<Task>> grouped = {};
    for (final task in tasks) {
      if (task.dueDate != null) {
        final dayKey = _stripTime(task.dueDate!);
        grouped.putIfAbsent(dayKey, () => []).add(task);
      }
    }
    setState(() {
      _events = grouped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Calendar', style: TextStyle(color: Colors.purple[50], fontWeight: FontWeight.bold,
              letterSpacing: .5,),),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent[700],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoaded) {
            _groupTasksByDate(state.tasks);
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TaskLoaded) {
            return Column(
              children: [
                TableCalendar<Task>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.indigoAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _getEventsForDay(_selectedDay!).isEmpty
                      ? Center(
                          child: Text(
                            'No tasks for ${DateFormat.yMMMd().format(_selectedDay!)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: _getEventsForDay(_selectedDay!).map((task) {
                            return Card(
                              color: Colors.indigoAccent[700],
                              child: ListTile(
                                leading: Icon(Icons.event_note, color: Colors.purple[50]),
                                title: Text(
                                  task.title,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Priority: ${task.priority}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Checkbox(
                                  value: task.done,
                                  onChanged: (value) {
                                    final updatedTask = task.copyWith(done: value);
                                    context.read<TaskBloc>().add(UpdateTask(updatedTask));
                                  },
                                  checkColor: Colors.purple[50],
                                  activeColor: Colors.green,
                                  side: BorderSide(
                                    color: Colors.purple[50]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            );
          }
          if (state is TaskError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No tasks loaded'));
        },
      ),
    );
  }
}
