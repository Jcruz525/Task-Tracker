import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String priority;
  final DateTime? dueDate;
  final bool recurring;
  final bool done;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.priority,
    this.dueDate,
    required this.recurring,
    required this.done,
    required this.createdAt
  });
@override
  List<Object?> get props => [id, title, priority, dueDate, recurring, done, createdAt];

  factory Task.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      priority: data['priority'] ?? 'Medium',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      recurring: data['recurring'] ?? false,
      done: data['done'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  factory Task.fromMap(String id, Map<String, dynamic> data) {
  return Task(
    id: id,
    title: data['title'] ?? '',
    priority: data['priority'] ?? 'Medium',
    dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
    recurring: data['recurring'] ?? false,
    done: data['done'] ?? false,
    createdAt: (data['createdAt'] as Timestamp).toDate(),
  );
}


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'priority': priority,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'recurring': recurring,
      'done': done,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? priority,
    DateTime? dueDate,
    bool? recurring,
    bool? done,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      recurring: recurring ?? this.recurring,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
