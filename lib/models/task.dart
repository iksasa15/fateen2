import 'package:flutter/material.dart';

class Task {
  String id;
  String name;
  String description;
  DateTime dueDate;
  TimeOfDay reminder;
  bool reminderStatus;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.dueDate,
    required this.reminder,
    this.reminderStatus = false,
  });

  // تحديث حالة المهمة
  void updateStatus(bool status) {
    reminderStatus = status;
  }

  // استرجاع جميع المهام
  static List<Task> getAllTasks(List<Task> tasks) {
    return tasks;
  }

  // إنشاء مهمة جديدة
  static void createTask(List<Task> tasks, Task task) {
    tasks.add(task);
  }

  // حذف مهمة
  static void deleteTask(List<Task> tasks, String taskId) {
    tasks.removeWhere((task) => task.id == taskId);
  }

  // تعديل مهمة
  static void updateTask(List<Task> tasks, String taskId, Task updatedTask) {
    int index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      tasks[index] = updatedTask;
    }
  }

  // استرجاع بيانات مهمة معينة
  static Task? getTask(List<Task> tasks, String taskId) {
    return tasks.firstWhere((task) => task.id == taskId,
        orElse: () => Task(
            id: '',
            name: '',
            description: '',
            dueDate: DateTime.now(),
            reminder: TimeOfDay.now()));
  }

  // استرجاع قائمة التذكيرات
  static List<Task> getReminders(List<Task> tasks) {
    return tasks.where((task) => task.reminderStatus).toList();
  }
}
