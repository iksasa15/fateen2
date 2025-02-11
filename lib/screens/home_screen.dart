import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fateen/models/student.dart';
import 'edit_profile_screen.dart'; // استيراد صفحة التعديل الجديدة

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const StudySchedulePage(),
    const CoursesPage(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'الجدول الدراسي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'المقررات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'خدمات AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ---------- الصفحات الفرعية ----------

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

class StudySchedulePage extends StatelessWidget {
  const StudySchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'هنا سيتم عرض الجدول الدراسي',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  final List<String> courses = const [
    "البرمجة بلغة Dart",
    "تطوير تطبيقات Flutter",
    "تصميم واجهات المستخدم",
    "قواعد البيانات",
    "الذكاء الاصطناعي",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.book, color: Colors.blue),
            title: Text(
              courses[index],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {},
          ),
        );
      },
    );
  }
}

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
