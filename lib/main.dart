import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// تعريف كلاس إدارة الإشعارات عالمياً داخل الملف
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إعدادات التهيئة لنظام أندرويد
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // تهيئة بلجن الإشعارات
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const DawaiProApp());
}

class DawaiProApp extends StatelessWidget {
  const DawaiProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DAWAI PRO 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1118),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF88), // أخضر زمردي
          surface: Color(0xFF111E2E), // كحلي فاخر
        ),
      ),
      home: const AddMedicineScreen(),
    );
  }
}

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  String _selectedTimeText = "لم يتم اختيار الوقت بعد";
  TimeOfDay? _selectedTime;

  // دالة اختيار الوقت بصرياً
  Future<void> _pickMedicineTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FF88),
              surface: Color(0xFF111E2E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedTimeText = picked.format(context);
      });
      // تجربة إرسال إشعار فوري عند اختيار الوقت للتأكد من عمل النظام
      _showTestNotification();
    }
  }

  // دالة اختبار إرسال الإشعار الطبي الفاخر
  Future<void> _showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dawai_pro_channel_id',
      'تنبيهات الأدوية',
      channelDescription: 'قناة خاصة بمنبهات الأدوية الموثوقة',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF00FF88),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'دوائي برو | موعد الدواء',
      'حان الآن وقت تناول جرعة الدواء المحددة في: $_selectedTimeText',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دوائي برو | DAWAI PRO 1'),
        backgroundColor: const Color(0xFF111E2E),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'إضافة موعد دواء جديد',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF88),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // زر اختيار الوقت بصرياً
            ElevatedButton.icon(
              onPressed: () => _pickMedicineTime(context),
              icon: const Icon(Icons.access_time, color: Color(0xFF00FF88)),
              label: Text(
                _selectedTimeText,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111E2E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF00FF88), width: 1),
                ),
              ),
            ),
            
            const Spacer(),

            // حقوق التطوير المهنية
            const Center(
              child: Text(
                'تطوير المهندس مهند محمد علي',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
