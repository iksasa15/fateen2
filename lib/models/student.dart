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

  // 🔹 دالة تسجيل طالب جديد
  static Future<String?> registerStudent({
    required String name,
    required String major,
    required String email,
    required String password,
  }) async {
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
