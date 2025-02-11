import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart'; // لإنشاء معرف فريد لكل مهمة

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  DateTime dueDate = DateTime.now();
  TimeOfDay reminder = TimeOfDay.now();
  bool reminderStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة مهمة جديدة')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'اسم المهمة'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'الرجاء إدخال اسم المهمة';
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'وصف المهمة'),
                onSaved: (value) {
                  description = value!;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('تاريخ التسليم: ${dueDate.toLocal()}'.split(' ')[0]),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dueDate = pickedDate;
                        });
                      }
                    },
                    child: Text('اختر'),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('وقت التذكير: ${reminder.format(context)}'),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: reminder,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          reminder = pickedTime;
                        });
                      }
                    },
                    child: Text('اختر'),
                  ),
                ],
              ),
              SwitchListTile(
                title: Text('تفعيل التذكير'),
                value: reminderStatus,
                onChanged: (value) {
                  setState(() {
                    reminderStatus = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Task newTask = Task(
                      id: Uuid().v4(),
                      name: name,
                      description: description,
                      dueDate: dueDate,
                      reminder: reminder,
                      reminderStatus: reminderStatus,
                    );
                    Navigator.pop(context, newTask);
                  }
                },
                child: Text('إضافة المهمة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
