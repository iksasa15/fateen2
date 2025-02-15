import 'task.dart';
import 'reminder.dart';

class Course {
  // الخصائص
  String id;
  String courseName;
  int creditHours;
  // استبدلنا DateTime بـ List<String> لحفظ أيام الأسبوع
  List<String> days;
  String classroom;
  Map<String, double> grades;
  List<Task> tasks;
  List<Reminder> reminders;
  // حقل جديد يتيح حفظ وقت المحاضرة على شكل نص
  String? lectureTime;

  // **المُنشئ**
  Course({
    required this.id,
    required this.courseName,
    required this.creditHours,
    required this.days,
    required this.classroom,
    Map<String, double>? grades,
    List<Task>? tasks,
    List<Reminder>? reminders,
    this.lectureTime,
  })  : grades = grades ?? {},
        tasks = tasks ?? [],
        reminders = reminders ?? [];

  // دالة تحوّل كائن Course إلى Map (مثال لحفظه في فايرستور)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseName': courseName,
      'creditHours': creditHours,
      'days': days,
      'classroom': classroom,
      'grades':
          grades, // أو قد تختار تحويلها إلى Map<String, double> بتنسيق آخر
      'lectureTime': lectureTime,
      // إذا احتجت حفظ الـ tasks أو reminders أيضًا
      // يمكنك تحويلهما إلى List<Map<String, dynamic>> إذا لزم الأمر
    };
  }

  // دالة تولّد كائن Course من Map (مثال لاستعادته من فايرستور)
  factory Course.fromMap(Map<String, dynamic> map, String docId) {
    return Course(
      id: map['id'] ?? docId,
      courseName: map['courseName'] ?? '',
      creditHours: map['creditHours'] ?? 0,
      days: List<String>.from(map['days'] ?? []),
      classroom: map['classroom'] ?? '',
      grades: Map<String, double>.from(map['grades'] ?? {}),
      lectureTime: map['lectureTime'],
      // إذا أردت تعبئة الـ tasks أو reminders من الـ Map
      // يجب عليك كتابة دوال fromMap خاصة بكل كائن Task أو Reminder كذلك
    );
  }

  // **الدوال الأساسية**
  void createCourse() {
    print("📚 تم إنشاء الكورس: $courseName");
  }

  void deleteCourse() {
    print("🗑 تم حذف الكورس: $courseName");
  }

  // عدلنا الدالة لتستقبل قائمة أيام بدل وقت المحاضرة
  void modifyCourseDetails(
    String name,
    int hours,
    List<String> newDays,
    String room,
  ) {
    courseName = name;
    creditHours = hours;
    days = newDays;
    classroom = room;
    print("✏ تم تعديل تفاصيل الكورس: $courseName");
  }

  void viewCourseDetails() {
    print("🔹 تفاصيل الكورس:");
    print("📌 الاسم: $courseName");
    print("📚 عدد الساعات: $creditHours");
    // نطبع الأيام المحددة للمحاضرات
    print("📅 أيام المحاضرة: ${days.join('، ')}");
    print("🏫 القاعة: $classroom");
    // إذا كان وقت المحاضرة موجودًا، نطبع قيمته
    if (lectureTime != null) {
      print("⏰ وقت المحاضرة: $lectureTime");
    }
  }

  // إضافة مهمة (Task) للكورس
  void createTask(Task task) {
    tasks.add(task);
    print("✅ تمت إضافة المهمة '${task.name}' إلى الكورس '$courseName'");
  }

  // عرض جميع المهام الخاصة بالكورس
  void viewTasks() {
    print("📌 المهام الخاصة بالكورس '$courseName':");
    for (var task in tasks) {
      print("- ${task.name} (🔹 الحالة: ${task.status})");
    }
  }

  // تعديل اسم مهمة محددة
  void modifyTask(String taskId, String newName) {
    for (var task in tasks) {
      if (task.id == taskId) {
        task.name = newName;
        print("✏ تم تعديل اسم المهمة إلى '$newName'");
        return;
      }
    }
    print("⚠ لم يتم العثور على المهمة!");
  }

  // إضافة درجة جديدة
  void createGrade(String assignment, double grade) {
    grades[assignment] = grade;
    print(
        "📊 تمت إضافة درجة '$grade' لـ '$assignment' في الكورس '$courseName'");
  }

  // تعديل درجة موجودة
  void modifyGrade(String assignment, double newGrade) {
    if (grades.containsKey(assignment)) {
      grades[assignment] = newGrade;
      print("✏ تم تعديل درجة '$assignment' إلى '$newGrade'");
    } else {
      print("⚠ لم يتم العثور على التقييم '$assignment'");
    }
  }

  // عرض جميع الدرجات
  void viewGrades() {
    print("📊 درجات الكورس '$courseName':");
    grades.forEach((assignment, grade) {
      print("- $assignment: $grade");
    });
  }

  // إضافة تذكير (Reminder) يخص محاضرة أو مهمة
  void createLectureReminder(Reminder reminder) {
    reminders.add(reminder);
    print("📅 تم تعيين تذكير لمحاضرة '$courseName'");
  }

  // تعديل محتوى تذكير محدد
  void modifyReminder(String reminderId, String newMessage) {
    for (var reminder in reminders) {
      if (reminder.id == reminderId) {
        reminder.message = newMessage;
        print("🔔 تم تعديل التذكير إلى: '$newMessage'");
        return;
      }
    }
    print("⚠ لم يتم العثور على التذكير!");
  }

  // عرض جميع التذكيرات
  void viewReminders() {
    print("📝 التذكيرات الخاصة بالكورس '$courseName':");
    for (var reminder in reminders) {
      print("- ${reminder.message} (📆 في: ${reminder.reminderTime})");
    }
  }

  // حذف تذكير من القائمة
  void deleteReminder(String reminderId) {
    reminders.removeWhere((reminder) => reminder.id == reminderId);
    print("🗑 تم حذف التذكير بنجاح!");
  }
}
