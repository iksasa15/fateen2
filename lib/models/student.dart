import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Student {
  String? userId;
  String? name;
  String? major;
  String? email;

  Student({
    this.userId,
    this.name,
    this.major,
    this.email,
  });

  // تحويل بيانات الطالب إلى Map لحفظها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'major': major,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // 🔹 التحقق من صحة الاسم (يجب أن يكون نصًا بدون أرقام)
  static bool isValidName(String name) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(name);
  }

  // 🔹 التحقق من صحة التخصص (يجب أن يكون نصًا بدون أرقام)
  static bool isValidMajor(String major) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(major);
  }

  // 🔹 التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 🔹 التحقق من صحة كلمة المرور
  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) && // يحتوي على حرف كبير
        RegExp(r'[a-z]').hasMatch(password) && // يحتوي على حرف صغير
        RegExp(r'\d').hasMatch(password) && // يحتوي على رقم
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]')
            .hasMatch(password); // يحتوي على رمز خاص
  }

  // 🔹 دالة تسجيل طالب جديد
  static Future<String?> registerStudent({
    required String name,
    required String major,
    required String email,
    required String password,
  }) async {
    if (!isValidName(name)) {
      return "❌ الاسم يجب أن يحتوي على أحرف فقط بدون أرقام.";
    }

    if (!isValidMajor(major)) {
      return "❌ التخصص يجب أن يحتوي على أحرف فقط بدون أرقام.";
    }

    if (!isValidEmail(email)) {
      return "❌ يرجى إدخال بريد إلكتروني صحيح.";
    }

    if (!isValidPassword(password)) {
      return "❌ يجب أن تحتوي كلمة المرور على 8 خانات على الأقل، وحرف كبير، وحرف صغير، ورقم، ورمز خاص.";
    }

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String userId = userCredential.user!.uid;

      Student student = Student(
        userId: userId,
        name: name,
        major: major,
        email: email,
      );

      await firestore.collection('users').doc(userId).set(student.toMap());

      return null; // نجاح
    } catch (e) {
      return e.toString(); // في حالة الخطأ
    }
  }

  // 🔹 دالة تسجيل الدخول
  static Future<String?> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return null; // نجاح
    } catch (e) {
      return e.toString(); // فشل تسجيل الدخول
    }
  }
}
