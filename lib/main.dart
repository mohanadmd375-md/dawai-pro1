import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'add_medication_screen.dart';

void main() {
  runApp(const DawaiProApp());
}

class DawaiProApp extends StatelessWidget {
  const DawaiProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DAWAI PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // دالة لجلب الأدوية من قاعدة البيانات
  Future<void> _loadMedications() async {
    final data = await DatabaseHelper.instance.queryAllMedications();
    setState(() {
      _medications = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دوائي برو - DAWAI PRO'),
      ),
      body: _medications.isEmpty
          ? const Center(
              child: Text(
                'لا توجد أدوية مضافة حالياً',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final med = _medications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      med['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('الجرعة: ${med['dosage']} | الموعد: ${med['time']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteMedication(med['id']);
                        _loadMedications();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // الانتقال لشاشة إضافة الدواء والانتظار حتى العودة لتحديث القائمة
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicationScreen(),
            ),
          );
          if (result == true) {
            _loadMedications();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
