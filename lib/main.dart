import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(const DawaiProAlarmApp());
}

class DawaiProAlarmApp extends StatelessWidget {
  const DawaiProAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DAWAI PRO ALARM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1118),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF88),
          surface: Color(0xFF111E2E),
        ),
      ),
      home: const MorningStyleAlarmScreen(),
    );
  }
}

class MorningStyleAlarmScreen extends StatefulWidget {
  const MorningStyleAlarmScreen({super.key});

  @override
  State<MorningStyleAlarmScreen> createState() => _MorningStyleAlarmScreenState();
}

class _MorningStyleAlarmScreenState extends State<MorningStyleAlarmScreen> {
  static const int _alarmId = 101;
  String _timeLabel = "لم يتم ضبط منبه بعد";
  String _statusLabel = "اختر ساعة ودقيقة ثم أغلق التطبيق واختبر الرنين";

  Future<void> _pickAlarmTime() async {
    final picked = await showTimePicker(
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

    if (picked == null) return;

    final now = DateTime.now();
    var targetDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    if (!targetDateTime.isAfter(now)) {
      targetDateTime = targetDateTime.add(const Duration(days: 1));
    }

    try {
      final alarmSettings = AlarmSettings(
        id: _alarmId,
        dateTime: targetDateTime,
        assetAudioPath: null,
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: true,
        androidFullScreenIntent: true,
        volumeSettings: VolumeSettings.fade(
          volume: 1.0,
          fadeDuration: const Duration(seconds: 3),
          volumeEnforced: true,
        ),
        notificationSettings: NotificationSettings(
          title: '⏰ منبه الدواء - DAWAI PRO',
          body: 'حان موعد الدواء المحدد الساعة ${picked.format(context)}',
          stopButton: 'إيقاف المنبه',
          icon: 'mipmap/ic_launcher',
        ),
      );

      final success = await Alarm.set(alarmSettings: alarmSettings);

      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

      setState(() {
        _timeLabel = formatted;
        _statusLabel = success
            ? "تم ضبط المنبه على $formatted — سيظل يرن حتى توقفه."
            : "تعذر تفعيل المنبه — تحقق من صلاحيات المنبهات والإشعارات في الهاتف.";
      });
    } catch (e) {
      setState(() {
        _statusLabel = "خطأ أثناء ضبط المنبه: $e";
      });
    }
  }

  Future<void> _stopAlarm() async {
    await Alarm.stop(_alarmId);
    setState(() {
      _statusLabel = "تم إيقاف المنبه.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAWAI PRO | منبه بصوت مستمر'),
        backgroundColor: const Color(0xFF111E2E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.alarm_on_rounded,
              size: 82,
              color: Color(0xFF00FF88),
            ),
            const SizedBox(height: 16),
            const Text(
              'موعد المنبه:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _timeLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickAlarmTime,
              icon: const Icon(Icons.access_time_filled),
              label: const Text('اختيار وقت المنبه'),
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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _stopAlarm,
              icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
              label: const Text(
                'إيقاف المنبه الحالي',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                _statusLabel,
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
