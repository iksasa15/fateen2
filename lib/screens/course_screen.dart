// lib/screens/course_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// حزم لاختيار الملفات وفتحها
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

import '../models/course.dart';
import '../models/app_file.dart';
import '../models/task.dart';

class CourseScreen extends StatefulWidget {
  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  User? currentUser;
  List<Course> courses = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController creditController = TextEditingController();
  final TextEditingController classroomController = TextEditingController();
  List<String> selectedDays = [];
  String? selectedTimeString;

  // حقول خاصة بالدرجات
  final TextEditingController _assignmentController = TextEditingController();
  final TextEditingController _gradeValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchCoursesFromFirestore();
  }

  /// جلب المقررات من فايرستور
  Future<void> _fetchCoursesFromFirestore() async {
    if (currentUser == null) return;
    try {
      final userId = currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      final List<Course> loadedCourses = snapshot.docs.map((doc) {
        final data = doc.data();
        return Course.fromMap(data, doc.id);
      }).toList();

      setState(() {
        courses = loadedCourses;
      });
    } catch (e) {
      print('حدث خطأ أثناء جلب المقررات: $e');
    }
  }

  // BottomSheet لإضافة/تعديل المقرر
  void _showCourseBottomSheet({Course? course, int? index}) {
    bool isEditing = (course != null);

    // تعبئة الحقول
    nameController.text = isEditing ? course!.courseName : '';
    creditController.text = isEditing ? course!.creditHours.toString() : '';
    classroomController.text = isEditing ? course!.classroom : '';
    selectedDays = isEditing ? List<String>.from(course!.days) : [];
    selectedTimeString = isEditing ? course!.lectureTime : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'تعديل المقرر' : 'إضافة مقرر جديد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "اسم المقرر"),
                  ),
                  TextField(
                    controller: creditController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "عدد الساعات"),
                  ),
                  TextField(
                    controller: classroomController,
                    decoration: InputDecoration(labelText: "قاعة المحاضرة"),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      'الأحد',
                      'الإثنين',
                      'الثلاثاء',
                      'الأربعاء',
                      'الخميس',
                    ].map((day) {
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
                  SizedBox(height: 10),
                  ListTile(
                    title: Text(selectedTimeString == null
                        ? 'حدد وقت المحاضرة'
                        : 'وقت المحاضرة: $selectedTimeString'),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        String formattedTime =
                            '${pickedTime.hour.toString().padLeft(2, '0')}:'
                            '${pickedTime.minute.toString().padLeft(2, '0')}';
                        setState(() {
                          selectedTimeString = formattedTime;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text("إلغاء"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isNotEmpty &&
                              creditController.text.isNotEmpty &&
                              classroomController.text.isNotEmpty &&
                              selectedDays.isNotEmpty) {
                            final creditValue =
                                int.tryParse(creditController.text) ?? 0;

                            if (isEditing && index != null) {
                              // التعديل
                              course!.modifyCourseDetails(
                                nameController.text,
                                creditValue,
                                selectedDays,
                                classroomController.text,
                                selectedTimeString,
                              );
                              // حفظ في فايرستور (إذا تحتاجه)
                              await course.saveToFirestore(currentUser);
                              setState(() {
                                courses[index] = course;
                              });
                            } else {
                              // الإضافة
                              final newCourse = Course(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                courseName: nameController.text,
                                creditHours: creditValue,
                                days: selectedDays,
                                classroom: classroomController.text,
                                lectureTime: selectedTimeString,
                                grades: {},
                                tasks: [],
                                reminders: [],
                                files: [], // قائمة ملفات فارغة
                              );
                              setState(() {
                                courses.add(newCourse);
                              });
                              // حفظ في فايرستور
                              await newCourse.saveToFirestore(currentUser);
                            }

                            Navigator.pop(ctx);
                          }
                        },
                        child: Text("حفظ"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // حذف كورس
  void _deleteCourse(int index) async {
    final course = courses[index];
    setState(() {
      courses.removeAt(index);
    });

    await course.deleteFromFirestore(currentUser);
  }

  // -----------------------------------------------
  //    واجهة الدرجات: عرض وإنشاء/تعديل الدرجات
  // -----------------------------------------------

  // BottomSheet لعرض الدرجات الخاصة بكل كورس
  void _showGradesBottomSheet(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'درجات المقرر: ${course.courseName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (course.grades.isEmpty) ...[
                Text('لا توجد درجات مسجّلة بعد 🤔'),
                SizedBox(height: 10),
              ] else ...[
                ListView(
                  shrinkWrap: true, // حتى لا يملأ كامل الشاشة
                  children: course.grades.entries.map((entry) {
                    final assignment = entry.key;
                    final gradeValue = entry.value;
                    return ListTile(
                      title: Text('$assignment: $gradeValue'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showGradeDialog(course, assignment, gradeValue);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('إضافة درجة'),
                onPressed: () {
                  _showGradeDialog(course, null, null);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // BottomSheet لإضافة أو تعديل درجة
  void _showGradeDialog(Course course, String? assignment, double? oldGrade) {
    bool isEditing = (assignment != null && oldGrade != null);
    // تعبئة الحقول إذا كنا نعدل درجة
    _assignmentController.text = isEditing ? assignment! : '';
    _gradeValueController.text = isEditing ? oldGrade!.toString() : '';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'تعديل الدرجة' : 'إضافة درجة جديدة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _assignmentController,
                decoration: InputDecoration(labelText: 'اسم التقييم'),
              ),
              TextField(
                controller: _gradeValueController,
                decoration: InputDecoration(labelText: 'الدرجة (0-100)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final assignmentName = _assignmentController.text.trim();
                      final newGrade =
                          double.tryParse(_gradeValueController.text) ?? -1;

                      if (assignmentName.isNotEmpty && newGrade >= 0) {
                        setState(() {
                          if (isEditing) {
                            // تعديل درجة
                            // إذا تغيّر اسم التقييم، نحذف القديم وننشئ جديد
                            if (assignment != assignmentName) {
                              course.grades.remove(assignment);
                            }
                            course.modifyGrade(assignmentName, newGrade);
                          } else {
                            // إضافة درجة جديدة
                            course.createGrade(assignmentName, newGrade);
                          }
                        });

                        // حفظ التحديث في فايرستور
                        await course.saveToFirestore(currentUser);

                        // إغلاق BottomSheet تعديل الدرجة
                        Navigator.pop(ctx);
                        // إغلاق BottomSheet عرض الدرجات
                        Navigator.pop(ctx);
                        // إعادة فتح BottomSheet الدرجات حتى نعرض التحديثات
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

  // -----------------------------------------------
  //    واجهة الملفات: عرض وإنشاء/تعديل/حذف الملفات
  // -----------------------------------------------

  void _showFilesBottomSheet(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // دالة داخلية لإعادة البناء في الـ BottomSheet
            void refresh() => setModalState(() {});

            return Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ملفات المقرر: ${course.courseName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (course.files.isEmpty) ...[
                    Text('لا توجد ملفات لهذا المقرر بعد 🤔'),
                    SizedBox(height: 10),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: course.files.length,
                      itemBuilder: (context, index) {
                        final appFile = course.files[index];
                        return ListTile(
                          title:
                              Text('${appFile.fileName} (${appFile.fileType})'),
                          subtitle: Text('الحجم: ${appFile.fileSize} KB'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                tooltip: 'عرض الملف',
                                onPressed: () async {
                                  // أولاً, عرض التفاصيل في الـ Console إن شئت
                                  appFile.viewDetailsInConsole();

                                  // ثم محاولة فتح الملف بواسطة تطبيق مناسب
                                  if (appFile.filePath != null) {
                                    final result =
                                        await OpenFilex.open(appFile.filePath!);
                                    // يمكنك معاينة النتيجة في الـConsole:
                                    // result.type == ResultType.done => نجحت العملية
                                    // result.message => رسالة الخطأ إن وجدت
                                    debugPrint('OpenFilex result: $result');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('لا يوجد مسار لهذا الملف!'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: 'حذف',
                                onPressed: () async {
                                  // حذف الملف من الكورس
                                  setState(() {
                                    course.removeFile(appFile);
                                  });
                                  appFile.deleteFile();
                                  // حفظ التعديل في فايرستور
                                  await course.saveToFirestore(currentUser);
                                  refresh();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('إضافة ملف'),
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      if (result != null && result.files.isNotEmpty) {
                        final pickedFile = result.files.first;
                        // استخراج المعلومات
                        final fileName = pickedFile.name;
                        final fileSize = pickedFile.size ~/ 1024; // بالـ KB
                        final extension = pickedFile.extension ?? 'UNKNOWN';
                        final fileType = extension.toUpperCase();
                        final filePath = pickedFile.path; // مسار الملف

                        // إنشاء كائن الملف
                        final newAppFile = AppFile(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          fileName: fileName,
                          fileSize: fileSize,
                          fileType: fileType,
                          filePath: filePath,
                        );

                        // استدعاء دالة الرفع (تستطيع تعديلها حسب احتياجك)
                        newAppFile.upload();

                        // إضافة الملف في قائمة الكورس
                        setState(() {
                          course.addFile(newAppFile);
                        });

                        // حفظ تحديث الكورس في فايرستور
                        await course.saveToFirestore(currentUser);

                        refresh();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ تم إضافة الملف "$fileName"'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // -----------------------------------------------
  //                واجهة البناء
  // -----------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📚 إدارة المقررات'),
        backgroundColor: Colors.blueAccent,
      ),
      body: courses.isEmpty
          ? Center(
              child: Text(
                'لا توجد مقررات متاحة 😢',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (ctx, index) {
                final course = courses[index];
                final daysString = course.days.join('، ');
                final lectureTimeStr = course.lectureTime ?? 'غير محدد';

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      course.courseName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'الأيام: $daysString\n'
                      'الوقت: $lectureTimeStr | '
                      'قاعة: ${course.classroom}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر لإدارة الملفات
                        IconButton(
                          icon: Icon(Icons.attach_file),
                          tooltip: 'الملفات',
                          onPressed: () => _showFilesBottomSheet(course),
                        ),
                        // زر لعرض الدرجات
                        IconButton(
                          icon: Icon(Icons.star),
                          tooltip: 'الدرجات',
                          onPressed: () => _showGradesBottomSheet(course),
                        ),
                        // زر تعديل المقرر
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showCourseBottomSheet(
                            course: course,
                            index: index,
                          ),
                        ),
                        // زر حذف
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
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
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
