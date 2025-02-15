// lib/models/task.dart
import 'package:flutter/material.dart';
import 'course.dart';

class Task {
  final String id;
  final String name;
  final String description;
  final DateTime dueDate;
  final Course course; // ربط المهام بكائن Course
  final String courseId; // معرّف الكورس للربط في قاعدة البيانات
  final DateTime? reminderTime;
  final String status;
  final List<String> reminders;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.dueDate,
    required this.course,
    required this.courseId,
    this.reminderTime,
    required this.status,
    required this.reminders,
  });
}
