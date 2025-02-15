import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/course.dart';

class CourseScreen extends StatefulWidget {
  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  // الأيام الممكن اختيارها
  final List<String> selectableDays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  // قائمة المقررات (سيتم تحميلها من فايرستور)
  List<Course> courses = [];

  // حقول التحكم (لإضافة أو تعديل المقرر)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController creditController = TextEditingController();
  final TextEditingController classroomController = TextEditingController();

  // الأيام المختارة مؤقتًا
  List<String> selectedDays = [];
  // الوقت المختار مؤقتًا (سنخزِّن قيمته بصيغة string)
  String? selectedTimeString;

  // مرجع إلى المستخدم الحالي (بعد تسجيل الدخول)
  User? currentUser;

  @override
  void initState() {
    super.initState();
    // نجلب بيانات المستخدم الحالي
    currentUser = FirebaseAuth.instance.currentUser;
    // نجلب المقررات من فايرستور
    _fetchCoursesFromFirestore();
  }

  /// جلب جميع المقررات من فايرستور للمستخدم الحالي
  Future<void> _fetchCoursesFromFirestore() async {
    if (currentUser == null) return; // تأكّد من وجود مستخدم أو تعامل مع الحالة

    try {
      final userId = currentUser!.uid;

      // جلب المستندات من المسار: users/{userId}/courses
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      // تحويل الداتا إلى كائنات Course
      final List<Course> loadedCourses = snapshot.docs.map((doc) {
        final data = doc.data();
        return Course(
          id: data['id'] ?? doc.id,
          courseName: data['courseName'],
          creditHours: data['creditHours'],
          days: List<String>.from(data['days'] ?? []),
          classroom: data['classroom'],
          lectureTime: data['lectureTime'],
          grades: Map<String, double>.from(data['grades'] ?? {}),
          // tasks / reminders لم نضفها في toMap() بالضرورة، حسب حاجتك
        );
      }).toList();

      setState(() {
        courses = loadedCourses;
      });
    } catch (e) {
      print('حدث خطأ أثناء جلب المقررات: $e');
    }
  }

  /// حفظ مقرر جديد أو تعديل مقرر موجود في فايرستور
  Future<void> _saveOrUpdateCourseInFirestore(Course course) async {
    if (currentUser == null) return; // تأكّد من وجود مستخدم

    final userId = currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(course.id);

    // تحويل الكائن إلى Map (اعتمدنا وجود toMap في كلاس Course؛ إن لم تكن موجودة، نكتب map هنا)
    final courseData = {
      'id': course.id,
      'courseName': course.courseName,
      'creditHours': course.creditHours,
      'days': course.days,
      'classroom': course.classroom,
      'lectureTime': course.lectureTime,
      'grades': course.grades,
      // إذا لديك حقول أخرى (tasks, reminders) وتريد حفظها، أضفها هنا أيضًا
    };

    await docRef.set(courseData, SetOptions(merge: true));
  }

  /// حذف مقرر من فايرستور
  Future<void> _deleteCourseFromFirestore(String courseId) async {
    if (currentUser == null) return;
    final userId = currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .delete();
  }

  /// فتح واجهة BottomSheet لإضافة/تعديل المقرر
  void _showCourseBottomSheet({Course? course, int? index}) {
    bool isEditing = course != null;

    // تعبئة الحقول إذا كنا نعدّل
    nameController.text = isEditing ? course!.courseName : '';
    creditController.text = isEditing ? course!.creditHours.toString() : '';
    classroomController.text = isEditing ? course!.classroom : '';
    selectedDays = isEditing ? List.from(course!.days) : [];
    selectedTimeString = isEditing ? course!.lectureTime : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // يسمح بتمديد الـBottomSheet
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          // لضمان عدم اختفاء الواجهة خلف لوحة المفاتيح
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'تعديل المقرر' : 'إضافة مقرر جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "اسم المقرر"),
                  ),
                  TextField(
                    controller: creditController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "عدد الساعات"),
                  ),
                  TextField(
                    controller: classroomController,
                    decoration:
                        const InputDecoration(labelText: "قاعة المحاضرة"),
                  ),
                  const SizedBox(height: 10),
                  // اختيار الأيام باستخدام ChoiceChip
                  Wrap(
                    spacing: 8.0,
                    children: selectableDays.map((day) {
                      bool isSelected = selectedDays.contains(day);
                      return ChoiceChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDays.add(day);
                            } else {
                              selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  // اختيار وقت المحاضرة
                  ListTile(
                    title: Text(selectedTimeString == null
                        ? 'حدد وقت المحاضرة'
                        : 'وقت المحاضرة: $selectedTimeString'),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      // إظهار أداة اختيار الوقت
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        // تنسيق الوقت لعرضه كنص  "12:30" مثلاً
                        String formattedTime =
                            pickedTime.hour.toString().padLeft(2, '0') +
                                ':' +
                                pickedTime.minute.toString().padLeft(2, '0');
                        setState(() {
                          selectedTimeString = formattedTime;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("إلغاء"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // التحقق من صحة الإدخال
                          if (nameController.text.isNotEmpty &&
                              creditController.text.isNotEmpty &&
                              classroomController.text.isNotEmpty &&
                              selectedDays.isNotEmpty &&
                              selectedTimeString != null) {
                            final newCourse = Course(
                              id: isEditing
                                  ? course!.id
                                  : DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              courseName: nameController.text,
                              creditHours: int.tryParse(
                                    creditController.text,
                                  ) ??
                                  0,
                              days: List.from(selectedDays),
                              classroom: classroomController.text,
                              lectureTime: selectedTimeString,
                              // إذا ننشئ مقرر جديد نضع الحقول الأخرى فارغة
                              // أما إن كنا نعدّل، نحتفظ بـ grades/tasks/reminders كما هي
                              grades: isEditing ? course!.grades : {},
                              tasks: isEditing ? course!.tasks : [],
                              reminders: isEditing ? course!.reminders : [],
                            );

                            setState(() {
                              if (isEditing && index != null) {
                                // تعديل المقرر في القائمة
                                courses[index] = newCourse;
                              } else {
                                // إضافة مقرر جديد
                                courses.add(newCourse);
                              }
                            });

                            // حفظ/تحديث في فايرستور
                            await _saveOrUpdateCourseInFirestore(newCourse);

                            Navigator.pop(context);
                          }
                        },
                        child: Text("حفظ"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // حذف مقرّر
  void _deleteCourse(int index) async {
    final course = courses[index];
    setState(() {
      courses.removeAt(index);
    });
    // نحذف أيضًا من فايرستور
    await _deleteCourseFromFirestore(course.id);
  }

  // -------------------------------------------------------
  // واجهة إدارة الدرجات (المواد --> الدرجات)
  // -------------------------------------------------------
  /// عرض قائمة بالدرجات الخاصة بمقرر معين، مع إمكانية إضافة أو تعديل الدرجات
  void _showGradesBottomSheet(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            // لضمان عدم اختفاء المحتوى خلف لوحة المفاتيح
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'درجات المقرر: ${course.courseName}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // عرض الدرجات إن وجدت
              if (course.grades.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'لا توجد درجات مسجّلة بعد 😢',
                  style: TextStyle(fontSize: 16),
                ),
              ] else ...[
                ListView(
                  shrinkWrap: true,
                  children: course.grades.entries.map((entry) {
                    final assignment = entry.key;
                    final gradeValue = entry.value;
                    return ListTile(
                      title: Text('$assignment: $gradeValue'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // فتح واجهة تعديل الدرجة
                          _showGradeDialog(course, assignment, gradeValue);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              // زر إضافة درجة جديدة
              ElevatedButton.icon(
                onPressed: () {
                  _showGradeDialog(course, null, null);
                },
                icon: Icon(Icons.add),
                label: Text('إضافة درجة'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// إضافة درجة جديدة أو تعديل درجة سابقة
  final TextEditingController _assignmentController = TextEditingController();
  final TextEditingController _gradeValueController = TextEditingController();

  void _showGradeDialog(Course course, String? assignment, double? oldGrade) {
    // تعبئة الحقول في حال كنا نعدّل
    bool isEditing = (assignment != null && oldGrade != null);
    _assignmentController.text = isEditing ? assignment : '';
    _gradeValueController.text = isEditing ? oldGrade.toString() : '';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'تعديل الدرجة' : 'إضافة درجة جديدة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _assignmentController,
                decoration: const InputDecoration(labelText: 'اسم التقييم'),
              ),
              TextField(
                controller: _gradeValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الدرجة (0-100)'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final assignmentName = _assignmentController.text.trim();
                      final gradeValue = double.tryParse(
                            _gradeValueController.text,
                          ) ??
                          -1;

                      // التحقق السريع من صحة البيانات
                      if (assignmentName.isNotEmpty && gradeValue >= 0) {
                        setState(() {
                          if (isEditing) {
                            // حذف اسم التقييم القديم وإضافة الجديد
                            // (في حال كانت الأسماء مختلفة)
                            if (assignment != assignmentName) {
                              course.grades.remove(assignment);
                            }
                            course.modifyGrade(assignmentName, gradeValue);
                          } else {
                            // إضافة درجة جديدة
                            course.createGrade(assignmentName, gradeValue);
                          }
                        });

                        // تحدّيث المقرر في فايرستور
                        await _saveOrUpdateCourseInFirestore(course);

                        Navigator.pop(
                            context); // إغلاق BottomSheet الخاصة بالدرجة
                        Navigator.pop(
                            context); // إغلاق BottomSheet الخاصة بقائمة الدرجات
                        // إعادة فتح قائمة الدرجات لتحديث العرض
                        _showGradesBottomSheet(course);
                      }
                    },
                    child: Text('حفظ'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------
  // واجهة البناء الرئيسية
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 إدارة المقررات'),
        backgroundColor: Colors.blueAccent,
      ),
      body: courses.isEmpty
          ? const Center(
              child: Text(
                'لا توجد مقررات متاحة 😢',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                // عرض الأيام كـ String
                final daysString = course.days.join('، ');
                final lectureTimeStr = (course.lectureTime != null)
                    ? course.lectureTime
                    : 'غير محدد';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      course.courseName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'الأيام: $daysString\n'
                      'الوقت: $lectureTimeStr | '
                      'قاعة: ${course.classroom}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // إدارة الدرجات
                        IconButton(
                          icon: const Icon(Icons.star),
                          onPressed: () => _showGradesBottomSheet(course),
                          tooltip: 'عرض الدرجات',
                        ),
                        // تعديل المقرر
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showCourseBottomSheet(
                              course: course, index: index),
                        ),
                        // حذف المقرر
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCourse(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourseBottomSheet(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
