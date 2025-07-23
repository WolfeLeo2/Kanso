import 'package:flutter/material.dart';

enum TaskType {
  meeting,
  task,
  habit;

  Color get color {
    switch (this) {
      case TaskType.meeting:
        return Colors.blue;
      case TaskType.task:
        return Colors.green;
      case TaskType.habit:
        return Colors.orange;
    }
  }

  String get name {
    switch (this) {
      case TaskType.meeting:
        return 'Meeting';
      case TaskType.task:
        return 'Task';
      case TaskType.habit:
        return 'Habit';
    }
  }
}

class Event {
  final String id;
  final String title;
  final DateTime dateTime;
  final DateTime? endTime;
  final String? notes;
  bool isCompleted;
  final TaskType taskType;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    this.endTime,
    this.notes,
    this.isCompleted = false,
    required this.taskType,
  });

  // Convert Event to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
      'taskType': taskType.toString().split('.').last,
    };
  }

  // Create Event from Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'].toString(),
      title: map['title'].toString(),
      dateTime: DateTime.parse(map['dateTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      notes: map['notes']?.toString(),
      isCompleted: map['isCompleted'] == 1,
      taskType: TaskType.values.firstWhere(
        (type) => type.toString() == 'TaskType.${map['taskType']}',
      ),
    );
  }

  // Create a copy of the event with some fields replaced
  Event copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? notes,
    bool? isCompleted,
    TaskType? taskType,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      taskType: taskType ?? this.taskType,
    );
  }
}
