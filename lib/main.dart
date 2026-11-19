import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel kAlarmChannel = AndroidNotificationChannel(
  'dawai_pro_alarm_channel_v3',
  'تنبيهات ومواعيد الأدوية',
  description: 'قناة إشعارات ومنبهات الأدوية الدقيقة',
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
      title: 'DAWAI PRO 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1118),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF88),
          surface: Color(0xFF111E2E),
        ),
      ),
      home: const TimerTestScreen(),
    );
  }
}

class TimerTestScreen extends StatefulWidget {
  const TimerTestScreen({super.key});

  @override
  State<TimerTestScreen> createState() => _TimerTestScreenState();
}

class _TimerTestScreenState extends State<TimerTestScreen> {
  String _statusText = "جاهز — ابدأ بالإشعار الفوري ثم جدولة دقيقة واحدة";

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

  Future<void> _showInstantNotification() async {
    await flutterLocalNotificationsPlugin.show(
      1,
      'DAWAI PRO | إشعار فوري',
      'إذا ظهر هذا الإشعار فالإشعارات تعمل على جهازك.',
      _buildDetails(),
    );

    setState(() {
      _statusText = "تم إرسال إشعار فوري الآن — تحقق من شريط الإشعارات";
    });
  }

  Future<void> _scheduleAfterOneMinute() async {
    final now = tz.TZDateTime.now(tz.local);
    final target = now.add(const Duration(minutes: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      'DAWAI PRO | منبه الموقت',
      'حان وقت المنبه المجدول (${target.hour.toString().padLeft(2, '0')}:${target.minute.toString().padLeft(2, '0')})',
      target,
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    setState(() {
      _statusText =
          "تم ضبط المنبه على ${target.hour.toString().padLeft(2, '0')}:${target.minute.toString().padLeft(2, '0')} — انتظر دقيقة كاملة";
    });
  }

  Future<void> _pickCustomTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      3,
      'DAWAI PRO | تنبيه وقت محدد',
      'تنبيه الموقت المختار (${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')})',
      scheduled,
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    setState(() {
      _statusText =
          "تمت جدولة الموقت على ${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAWAI PRO | فحص الإشعار والموقت'),
        backgroundColor: const Color(0xFF111E2E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _showInstantNotification,
              icon: const Icon(Icons.notifications_active),
              label: const Text('1. إشعار فوري الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: const Color(0xFF0A1118),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _scheduleAfterOneMinute,
              icon: const Icon(Icons.alarm),
              label: const Text('2. جدولة منبه بعد دقيقة واحدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111E2E),
                foregroundColor: const Color(0xFF00FF88),
                side: const BorderSide(color: Color(0xFF00FF88)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _pickCustomTime(context),
              icon: const Icon(Icons.access_time, color: Color(0xFF00FF88)),
              label: const Text(
                '3. اختيار وقت للموقت',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111E2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
