// lib/models/course.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task.dart';
import 'app_file.dart';

class Course {
  // الخصائص الأساسية
  String id;
  String courseName;
  int creditHours;
  List<String> days; // أيام المحاضرة
  String classroom;
  String? lectureTime; // إذا أردت الحفاظ عليها
  Map<String, double> grades;

  // المهام/التذكيرات
  List<Task> tasks;
  List<String> reminders;

  // **جديد**: قائمة الملفات
  List<AppFile> files;

  // المُنشئ
  Course({
    required this.id,
    required this.courseName,
    required this.creditHours,
    required this.days,
    required this.classroom,
    this.lectureTime,
    Map<String, double>? grades,
    List<Task>? tasks,
    List<String>? reminders,
    List<AppFile>? files,
  })  : grades = grades ?? {},
        tasks = tasks ?? [],
        reminders = reminders ?? [],
        files = files ?? [];

  // -------------------------------------
  // دوال عرض أو تعديل بيانات الكورس
  // -------------------------------------
  void viewCourseDetails() {
    print("🔹 تفاصيل الكورس:");
    print("📌 الاسم: $courseName");
    print("📚 عدد الساعات: $creditHours");
    print("📅 أيام المحاضرة: ${days.join('، ')}");
    print("🏫 القاعة: $classroom");
    if (lectureTime != null) {
      print("⏰ وقت المحاضرة: $lectureTime");
    }
  }

  void modifyCourseDetails(
    String newName,
    int newCreditHours,
    List<String> newDays,
    String newClassroom,
    String? newLectureTime, // الباراميتر الخامس
  ) {
    courseName = newName;
    creditHours = newCreditHours;
    days = newDays;
    classroom = newClassroom;
    lectureTime = newLectureTime;
    print("✏ تم تعديل تفاصيل الكورس: $courseName");
  }

  // -------------------------------------
  // دوال الدرجات (Grades)
  // -------------------------------------
  void createGrade(String assignment, double gradeValue) {
    grades[assignment] = gradeValue;
    print("📊 تمت إضافة درجة '$gradeValue' لـ '$assignment' في '$courseName'");
  }

  void modifyGrade(String assignment, double newGrade) {
    if (grades.containsKey(assignment)) {
      grades[assignment] = newGrade;
      print("✏ تم تعديل درجة '$assignment' إلى '$newGrade'");
    } else {
      print("⚠ لم يتم العثور على التقييم '$assignment'");
    }
  }

  // -------------------------------------
  // دوال الملفات (Files)
  // -------------------------------------
  void addFile(AppFile file) {
    files.add(file);
    print("📂 تمت إضافة ملف `${file.fileName}` إلى `$courseName`");
  }

  void removeFile(AppFile file) {
    files.remove(file);
    print("🗑 تمت إزالة ملف `${file.fileName}` من `$courseName`");
  }

  // -------------------------------------
  // تحويل إلى/من Map (لحفظ في فايرستور مثلًا)
  // -------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseName': courseName,
      'creditHours': creditHours,
      'days': days,
      'classroom': classroom,
      'lectureTime': lectureTime,
      'grades': grades,
      'reminders': reminders,
      // **جديد**: تحويل قائمة الملفات إلى List<Map>
      'files': files.map((f) => f.toMap()).toList(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map, String docId) {
    return Course(
      id: map['id'] ?? docId,
      courseName: map['courseName'] ?? '',
      creditHours: map['creditHours'] ?? 0,
      days: List<String>.from(map['days'] ?? []),
      classroom: map['classroom'] ?? '',
      lectureTime: map['lectureTime'],
      grades: Map<String, double>.from(map['grades'] ?? {}),
      reminders: List<String>.from(map['reminders'] ?? []),
      files: (map['files'] as List<dynamic>?)
              ?.map((fileMap) => AppFile.fromMap(fileMap))
              .toList() ??
          [],
    );
  }

  // -------------------------------------
  // دوال اختيارية للتعامل مع فايرستور
  // -------------------------------------
  Future<void> saveToFirestore(User? currentUser) async {
    if (currentUser == null) return;
    final userId = currentUser.uid;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(id);

    await docRef.set(toMap(), SetOptions(merge: true));
    print("✅ تم حفظ الكورس '$courseName' في فايرستور.");
  }

  Future<void> deleteFromFirestore(User? currentUser) async {
    if (currentUser == null) return;
    final userId = currentUser.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(id)
        .delete();

    print("🗑 تم حذف الكورس '$courseName' من فايرستور.");
  }
}
