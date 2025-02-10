import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String? userId;
  String? name;
  String? major;
  String? email;
  String? password;

  Student({
    this.userId,
    this.name,
    this.major,
    this.email,
    this.password,
  });

  // تحويل كائن الطالب إلى Map لحفظه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'major': major,
      'email': email,
      'password': password, // ⚠️ لا يُفضل تخزين كلمة المرور كنص عادي!
    };
  }

  // إضافة بيانات المستخدم إلى Firestore
  Future<void> saveToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(toMap());
      print("✅ تم حفظ المستخدم بنجاح في Firestore!");
    } catch (e) {
      print("❌ خطأ أثناء حفظ المستخدم: $e");
    }
  }
}
