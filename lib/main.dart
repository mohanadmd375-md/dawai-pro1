import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel kAlarmChannel = AndroidNotificationChannel(
  'dawai_pro_alarm_channel_v4',
  'منبهات أدوية دواي برو',
  description: 'قناة منبهات الأدوية المخصصة للأوقات المحددة',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(kAlarmChannel);
  await androidPlugin?.requestNotificationsPermission();
  await androidPlugin?.requestExactAlarmsPermission();

  runApp(const DawaiProApp());
}

class DawaiProApp extends StatelessWidget {
  const DawaiProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DAWAI PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1118),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF88),
          surface: Color(0xFF111E2E),
        ),
      ),
      home: const CustomAlarmScreen(),
    );
  }
}

class CustomAlarmScreen extends StatefulWidget {
  const CustomAlarmScreen({super.key});

  @override
  State<CustomAlarmScreen> createState() => _CustomAlarmScreenState();
}

class _CustomAlarmScreenScreenState extends State<CustomAlarmScreen> {} // syntax fix below

class CustomAlarmScreenState extends State<CustomAlarmScreen> {
  String _statusText = "جاهز — اختر ساعة محددة لضبط منبه الدواء";
  String _scheduledTimeStr = "لم يتم ضبط منبه بعد";

  NotificationDetails _buildDetails() {
    final androidDetails = AndroidNotificationDetails(
      kAlarmChannel.id,
      kAlarmChannel.name,
      channelDescription: kAlarmChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      color: const Color(0xFF00FF88),
      category: AndroidNotificationCategory.alarm,
    );
    return NotificationDetails(android: androidDetails);
  }

  Future<void> _pickAndScheduleAlarm(BuildContext context) async {
    // 1. فتح نافذة اختيار الوقت (الساعة والدقيقة)
    final TimeOfDay? pickedTime = await showTimePicker(
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

    if (pickedTime == null) return;

    // 2. حساب الوقت بتوقيت بغداد المحلي
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // إذا كان الوقت الذي اختاره المستخدم قد مضى اليوم، اجعله لليوم القادم
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 3. جدولة المنبه بدقة عالية تعمل حتى في وضع السبات
    await flutterLocalNotificationsPlugin.zonedSchedule(
      100,
      '💊 وقت الدواء - DAWAI PRO',
      'حاث موعد تناول الدواء المحدد في الساعة ${pickedTime.format(context)}',
      scheduledDate,
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    setState(() {
      _scheduledTimeStr =
          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      _statusText = "تم ضبط المنبه بنجاح! يمكنك إغلاق التطبيق الآن.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAWAI PRO | منبه الأدوية المخصص'),
        backgroundColor: const Color(0xFF111E2E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.alarm_add_rounded,
              size: 80,
              color: Color(0xFF00FF88),
            ),
            const SizedBox(height: 20),
            Text(
              'وقت المنبه الحالي:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _scheduledTimeStr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _pickAndScheduleAlarm(context),
              icon: const Icon(Icons.access_time_filled),
              label: const Text('اختر وقت المنبه (ساعة ودقيقة)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: const Color(0xFF0A1118),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111E2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
