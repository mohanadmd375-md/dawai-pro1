import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'alarm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة خدمة التنبيهات
  await AlarmService.init();

  runApp(const DawaiProApp());
}

class DawaiProApp extends StatelessWidget {
  const DawaiProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dawai Pro',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // القائمة المعرفة بالنوع السليم 100%
  List> _medications = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // جلب الأدوية من قاعدة البيانات
  Future<void> _loadMedications() async {
    final data = await DatabaseHelper.instance.queryAllMedications();
    setState(() {
      _medications = data;
    });
  }

  // إضافة دواء جديد مع جدولة إشعار تجريبي
  Future<void> _addMedication() async {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      return;
    }

    final row = {
      'name': _nameController.text,
      'dosage': _dosageController.text,
      'time': _timeController.text.isEmpty ? '08:00 AM' : _timeController.text,
      'notes': _notesController.text,
    };

    await DatabaseHelper.instance.insertMedication(row);

    // إرسال إشعار فوري عند الإضافة للتأكيد
    await AlarmService.showInstantNotification(
      'تمت إضافة دواء جديد',
      'دواء: ${_nameController.text} (${_dosageController.text})',
    );

    _nameController.clear();
    _dosageController.clear();
    _timeController.clear();
    _notesController.clear();

    _loadMedications();
    Navigator.pop(context);
  }

  // حذف دواء
  Future<void> _deleteMedication(int id) async {
    await DatabaseHelper.instance.deleteMedication(id);
    _loadMedications();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة دواء جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم الدواء'),
                ),
                TextField(
                  controller: _dosageController,
                  decoration: const InputDecoration(labelText: 'الجرعة (مثال: حبة واحدة)'),
                ),
                TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'وقت التناول (مثال: 08:00 AM)'),
                ),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _addMedication,
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dawai Pro - إدارة الأدوية'),
        centerTitle: true,
      ),
      body: _medications.isEmpty
          const Center(
              child: Text(
                'لا توجد أدوية مضافة حالياً.\nاضغط على زر + لإضافة دواء.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final med = _medications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.medical_services, color: Colors.white),
                    ),
                    title: Text(med['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الجرعة: ${med['dosage']} | الوقت: ${med['time']}\nملاحظات: ${med['notes']}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMedication(med['id']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
