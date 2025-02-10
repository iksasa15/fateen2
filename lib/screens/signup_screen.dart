import 'package:flutter/material.dart';
import 'package:fateen/models/student.dart'; // استيراد كلاس الطالب
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

  Future<void> registerUser() async {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        majorController.text.isNotEmpty) {
      String? errorMessage = await Student.registerStudent(
        name: nameController.text,
        major: majorController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ تم إنشاء الحساب بنجاح!'),
              backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ خطأ أثناء التسجيل: $errorMessage'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('❌ يرجى ملء جميع الحقول'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إنشاء حساب جديد")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "الاسم الكامل")),
            TextField(
                controller: majorController,
                decoration: const InputDecoration(labelText: "التخصص")),
            TextField(
                controller: emailController,
                decoration:
                    const InputDecoration(labelText: "البريد الإلكتروني")),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "كلمة المرور")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: registerUser, child: const Text("تسجيل")),
          ],
        ),
      ),
    );
  }
}
