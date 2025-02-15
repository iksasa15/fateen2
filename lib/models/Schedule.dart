import 'dart:core';
import 'course.dart';

class Schedule {
  // قائمة الكورسات في الجدول الدراسي
  List<Course> courses;

  // **المُنشئ**
  Schedule({List<Course>? courses}) : courses = courses ?? [];

  // **الدوال الأساسية**

  /// عرض الجدول الأسبوعي
  void displayWeeklySchedule() {
    if (courses.isEmpty) {
      print("📅 لا يوجد كورسات مسجلة في الجدول.");
      return;
    }

    print("📆 الجدول الأسبوعي:");
    for (var course in courses) {
      // طباعة قائمة الأيام بدلًا من وقت المحاضرة
      print(
          "- 🏫 ${course.courseName} | 🗓 أيام المحاضرة: ${course.days.join('، ')} | 📍 ${course.classroom}");
    }
  }

  /// عرض تفاصيل جميع الكورسات في الجدول
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

  /// هذه الدالة لم تعد صالحة مع خاصية `days`
  /// يمكنك تصميم خوارزمية جديدة تحدد المحاضرة القادمة حسب اليوم الحالي.
  Course? getNextLecture() {
    print("⚠ لم يعد possible حساب المحاضرة القادمة بناءً على days فقط.");
    // مثال: إرجاع null دائمًا أو تعديلها لتلائم الأيام.
    return null;
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
