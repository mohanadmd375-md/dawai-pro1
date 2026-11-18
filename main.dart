import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const DawaiProApp());
}

class DawaiProApp extends StatelessWidget {
  const DawaiProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dawai Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MedicationsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  _MedicationsScreenState createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshMedications();
  }

  // جلب البيانات من قاعدة البيانات وتحديث الشاشة
  void _refreshMedications() async {
    final data = await DatabaseHelper.instance.getMedications();
    setState(() {
      _medications = data;
      _isLoading = false;
    });
  }

  // دالة لإظهار نافذة إضافة دواء جديد
  void _showAddDialog() {
    final nameController = TextEditingController();
    final doseController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة دواء جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم الدواء'),
            ),
            TextField(
              controller: doseController,
              decoration: const InputDecoration(labelText: 'الجرعة (مثال: حبة واحدة)'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'الوقت (مثال: 8:00 صباحاً)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  doseController.text.isNotEmpty &&
                  timeController.text.isNotEmpty) {
                await DatabaseHelper.instance.insertMedication({
                  'name': nameController.text,
                  'dose': doseController.text,
                  'time': timeController.text,
                });
                Navigator.pop(context);
                _refreshMedications();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // حذف دواء
  void _deleteMed(int id) async {
    await DatabaseHelper.instance.deleteMedication(id);
    _refreshMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دواي برو - تتبع الأدوية'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد أدوية مضافة حالياً',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final med = _medications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          med['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('الجرعة: ${med['dose']}  |  الوقت: ${med['time']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMed(med['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
        tooltip: 'إضافة دواء',
      ),
    );
  }
}
