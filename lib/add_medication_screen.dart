import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({Key? key}) : super(key: key);

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _saveMedication() async {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الدواء والجرعة على الأقل')),
      );
      return;
    }

    await DatabaseHelper.instance.insertMedication({
      'name': _nameController.text,
      'dosage': _dosageController.text,
      'time': _timeController.text.isEmpty ? '08:00 ص' : _timeController.text,
      'notes': _notesController.text,
    });

    Navigator.pop(context, true); // العودة للشاشة الرئيسية وتحديث البيانات
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة دواء جديد'),
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
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'الموعد (مثال: 08:00 ص)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات إضافية'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveMedication,
              child: const Text('حفظ الدواء'),
            ),
          ],
        ),
      ),
    );
  }
}
