// lib/models/schedule.dart
import 'dart:core';
import 'course.dart';

class Schedule {
  // قائمة الكورسات في الجدول الدراسي
  final List<Course> courses;

  // **المُنشئ**
  Schedule({List<Course>? courses}) : courses = courses ?? [];

  // خريطة تربط اليوم (كاسم بالعربي) برقم (0 للأحد، 1 للإثنين، ...)
  static const Map<String, int> dayToIndex = {
    'الأحد': 0,
    'الإثنين': 1,
    'الثلاثاء': 2,
    'الأربعاء': 3,
    'الخميس': 4,
    'الجمعة': 5,
    'السبت': 6,
  };

  /// عرض الجدول الأسبوعي
  void displayWeeklySchedule() {
    if (courses.isEmpty) {
      print("📅 لا يوجد كورسات مسجلة في الجدول.");
      return;
    }

    print("📆 الجدول الأسبوعي:");
    for (var course in courses) {
      print(
          "- 🏫 ${course.courseName} | 🗓 أيام المحاضرة: ${course.days.join('، ')} | 📍 ${course.classroom}");
    }
  }

  /// عرض تفاصيل جميع الكورسات
  void displayCourseDetails() {
    if (courses.isEmpty) {
      print("📚 لا يوجد كورسات متاحة.");
      return;
    }

    print("📋 تفاصيل الكورسات:");
    for (var course in courses) {
      course.viewCourseDetails();
    }
  }

  /// هذه دالة تجريبية لتحديد أقرب محاضرة بناءً على اليوم الحالي
  Course? getNextLecture() {
    if (courses.isEmpty) return null;

    final now = DateTime.now();
    // في Dart: weekday الأحد=7، الاثنين=1، إلى السبت=6
    // نستخدم mod 7 لجعل الأحد=0
    final currentWeekdayIndex = now.weekday % 7;

    Course? nextCourse;
    int? minDelta;

    for (var course in courses) {
      for (var day in course.days) {
        final dayIndex = dayToIndex[day];
        if (dayIndex == null) continue;

        int delta = dayIndex - currentWeekdayIndex;
        if (delta < 0) {
          delta += 7; // الأسبوع التالي
        }

        if (minDelta == null || delta < minDelta) {
          minDelta = delta;
          nextCourse = course;
        }
      }
    }

    if (nextCourse == null) {
      print("⚠ لا يمكن حساب المحاضرة القادمة بدقة.");
    } else {
      print(
          "✅ أقرب محاضرة قادمة هي '${nextCourse.courseName}' خلال $minDelta يوم/أيام.");
    }

    return nextCourse;
  }

  /// إضافة كورس جديد إلى الجدول
  void addCourse(Course course) {
    courses.add(course);
    print("✅ تم إضافة الكورس '${course.courseName}' إلى الجدول.");
  }

  /// إزالة كورس من الجدول
  void removeCourse(String courseId) {
    courses.removeWhere((course) => course.id == courseId);
    print("🗑 تم إزالة الكورس من الجدول.");
  }
}
