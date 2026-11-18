import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
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
  List> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final data = await DatabaseHelper.instance.queryAllMedications();
    setState(() {
      _medications = data;
    });
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة دواء جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الدواء'),
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(labelText: 'الجرعة (مثال: حبة واحدة)'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'وقت التناول (مثال: 8:00 صباحاً)'),
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
                if (nameController.text.isNotEmpty) {
                  await DatabaseHelper.instance.insertMedication({
                    'name': nameController.text,
                    'dosage': dosageController.text,
                    'time': timeController.text,
                    'notes': '',
                  });
                  Navigator.pop(context);
                  _loadMedications();
                }
              },
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
        title: const Text('دواي برو - Dawai Pro'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
                    title: Text(med['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الجرعة: ${med['dosage']} | الوقت: ${med['time']}'),
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
        onPressed: _showAddDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
