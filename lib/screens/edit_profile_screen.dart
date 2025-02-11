// edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fateen/models/student.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _majorController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _majorController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    Student? student = await Student.getStudent(widget.userId);
    if (student != null) {
      setState(() {
        _nameController.text = student.name!;
        _majorController.text = student.major!;
        _emailController.text = student.email!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (value) =>
                    Student.isValidName(value!) ? null : 'اسم غير صحيح',
              ),
              TextFormField(
                controller: _majorController,
                decoration: const InputDecoration(labelText: 'التخصص'),
                validator: (value) =>
                    Student.isValidMajor(value!) ? null : 'تخصص غير صحيح',
              ),
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'البريد الإلكتروني'),
                validator: (value) => Student.isValidEmail(value!)
                    ? null
                    : 'بريد إلكتروني غير صحيح',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String? result = await Student.updateStudent(
                      userId: widget.userId,
                      newName: _nameController.text,
                      newMajor: _majorController.text,
                      newEmail: _emailController.text,
                    );
                    if (result == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم التحديث بنجاح!')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطأ: $result')),
                      );
                    }
                  }
                },
                child: const Text('حفظ التغييرات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
