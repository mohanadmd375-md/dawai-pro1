import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(initSettings);

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      notificationsPlugin.resolvePlatformSpecificImplementation<
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
      debugShowCheckedModeBanner: false,
      title: 'DAWAI PRO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MedicationAlarmScreen(),
    );
  }
}

class MedicationAlarmScreen extends StatefulWidget {
  const MedicationAlarmScreen({super.key});

  @override
  State<MedicationAlarmScreen> createState() => _MedicationAlarmScreenState();
}

class _MedicationAlarmScreenState extends State<MedicationAlarmScreen> {
  final TextEditingController _medicineController =
      TextEditingController(text: 'دواء الصباح');
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _alarmActive = false;

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _toggleAlarm() async {
    if (!_alarmActive) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'dawai_pro_channel',
        'تنبيهات الأدوية',
        channelDescription: 'تنبيه مستمر لمواعيد تناول الأدوية',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        ongoing: true,
        autoCancel: false,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );

      const NotificationDetails details =
          NotificationDetails(android: androidDetails);

      final String medName = _medicineController.text.trim().isEmpty
          ? 'موعد الدواء'
          : _medicineController.text.trim();

      final String timeText = _selectedTime.format(context);
      final tz.TZDateTime scheduledDate = _nextInstanceOfTime(_selectedTime);

      await notificationsPlugin.zonedSchedule(
        101,
        'DAWAI PRO - $medName',
        'حان وقت الدواء المجدول الساعة $timeText',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      setState(() {
        _alarmActive = true;
      });
    } else {
      await notificationsPlugin.cancel(101);
      setState(() {
        _alarmActive = false;
      });
    }
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAWAI PRO'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _medicineController,
              decoration: const InputDecoration(
                labelText: 'اسم الدواء',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              title: const Text('وقت التنبيه'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _toggleAlarm,
              icon: Icon(_alarmActive ? Icons.alarm_off : Icons.alarm_add),
              label: Text(
                _alarmActive ? 'إلغاء المنبه المجدول' : 'جدولة المنبه',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
