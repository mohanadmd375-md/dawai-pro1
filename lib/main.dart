import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة بيانات المناطق الزمنية وضبط توقيت بغداد
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // طلب صلاحيات الإشعارات والمنبهات الدقيقة على أندرويد (Android 13 / 14+)
  final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestNotificationsPermission();
  await androidPlugin?.requestExactAlarmsPermission();

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

      // جدولة المنبه الحقيقي في الوقت المختار
      await _scheduleMedicineAlarm(picked);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF111E2E),
            content: Text(
              'تم جدولة منبه الدواء بنجاح في الساعة: ${picked.format(context)}',
              style: const TextStyle(color: Color(0xFF00FF88)),
            ),
          ),
        );
      }
    }
  }

  // دالة جدولة المنبه في وقت محدد بدقة
  Future<void> _scheduleMedicineAlarm(TimeOfDay time) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // إذا كان الوقت المختار قد مضى اليوم، نجدوله لليوم التالي
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dawai_pro_alarm_channel',
      'منبهات مواعيد الأدوية',
      channelDescription: 'تنبيهات دقيقة لمواعيد الأدوية اليومية',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      color: Color(0xFF00FF88),
      category: AndroidNotificationCategory.alarm,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'DAWAI PRO | موعد الدواء',
      'حان الآن موعد تناول الدواء المجدول (${time.format(context)})',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
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
