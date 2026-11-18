import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _timeController = TextEditingController();

  void _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      await DatabaseHelper.instance.insertMedication({
        'name': _nameController.text,
        'dose': _doseController.text,
        'time': _timeController.text,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة دواء جديد'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الدواء',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال اسم الدواء' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'الجرعة (مثال: حبة واحدة)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال الجرعة' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'وقت التناول (مثال: 08:00 صباحاً)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال الوقت' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'حفظ الدواء',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
