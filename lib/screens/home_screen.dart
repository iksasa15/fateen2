import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_screen.dart';
import 'schedule_screen.dart';
import 'course_screen.dart';

import 'edit_profile_screen.dart'; // استيراد صفحة التعديل الجديدة

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ✅ تحديث قائمة الصفحات لتشمل جميع الشاشات المطلوبة
  final List<Widget> _pages = [
    const HomePage(),
    ScheduleScreen(),
    CourseScreen(),
    TaskScreen(),
    const AiServicesPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        backgroundColor: Colors.blue,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'الجدول'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'المقررات'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'المهام'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'الملفات'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy), label: 'خدمات AI'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ✅ الصفحة الرئيسية
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'مرحباً بك في الصفحة الرئيسية!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ✅ صفحة خدمات الذكاء الاصطناعي
class AiServicesPage extends StatelessWidget {
  const AiServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'خدمات الذكاء الاصطناعي قيد التطوير...',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ✅ صفحة الإعدادات
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'الإعدادات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(userId: user.uid),
                  ),
                );
              }
            },
            child: const Text('تعديل الملف الشخصي'),
          ),
        ],
      ),
    );
  }
}
