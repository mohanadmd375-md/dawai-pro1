import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'alarm_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({Key? key}) : super(key: key);

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  
  // وقت افتراضي للتنبيه (بعد دقيقة واحدة للتجربة، أو يمكن تخصيصه لاحقاً)
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMedication() async {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الدواء والجرعة على الأقل')),
      );
      return;
    }

    final timeString = _selectedTime.format(context);

    // 1. حفظ الدواء في قاعدة البيانات
    final int insertedId = await DatabaseHelper.instance.insertMedication({
      'name': _nameController.text,
      'dosage': _dosageController.text,
      'time': timeString,
      'notes': _notesController.text,
    });

    // 2. حساب وقت الإشعار اليومي أو القادم
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // إذا كان الوقت قد مر اليوم، نجعل التنبيه لليوم القادم
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 3. جدولة التنبيه الفعلي
    await AlarmService.scheduleNotification(
      id: insertedId,
      title: 'موعد دواء: ${_nameController.text}',
      body: 'حان وقت تناول الجرعة: ${_dosageController.text}',
      scheduledTime: scheduledDate,
    );

    Navigator.pop(context, true); // العودة للشاشة الرئيسية وتحديث القائمة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة دواء جديد مع التنبيه'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم الدواء'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'الجرعة (مثال: حبة واحدة)'),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('وقت التنبيه:'),
              trailing: Text(
                _selectedTime.format(context),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              onTap: () => _pickTime(context),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات إضافية'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveMedication,
              child: const Text('حفظ الدواء وجدولة التنبيه'),
            ),
          ],
        ),
      ),
    );
  }
}
