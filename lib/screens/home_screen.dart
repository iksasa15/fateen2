import 'package:flutter/material.dart';
import 'tasks_screen.dart'; // استيراد شاشة المهام
import 'login_screen.dart'; // استيراد شاشة تسجيل الدخول

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // قائمة الصفحات المرتبطة بكل عنصر في شريط التنقل
  final List<Widget> _pages = [
    HomePage(), // الصفحة الرئيسية
    StudySchedulePage(), // الجدول الدراسي
    CoursesPage(), // المقررات الدراسية
    AiServicesPage(), // خدمات AI
    SettingsPage(), // الإعدادات
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
      body: _pages[_selectedIndex], // عرض الصفحة المحددة حاليًا
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

// الصفحة الرئيسية مع زر الانتقال إلى صفحة المهام
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'مرحباً بك في الصفحة الرئيسية!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TasksScreen()),
              );
            },
            child: Text('عرض المهام'),
          ),
        ],
      ),
    );
  }
}

// صفحة الجدول الدراسي
class StudySchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'هنا سيتم عرض الجدول الدراسي',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// صفحة المقررات الدراسية
class CoursesPage extends StatelessWidget {
  final List<String> courses = [
    "البرمجة بلغة Dart",
    "تطوير تطبيقات Flutter",
    "تصميم واجهات المستخدم",
    "قواعد البيانات",
    "الذكاء الاصطناعي",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(Icons.book, color: Colors.blue),
            title: Text(
              courses[index],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {
              // يمكنك إضافة وظيفة لعرض تفاصيل المقرر
            },
          ),
        );
      },
    );
  }
}

// صفحة خدمات الذكاء الاصطناعي
class AiServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'خدمات الذكاء الاصطناعي قيد التطوير...',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// صفحة الإعدادات
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'الإعدادات',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
