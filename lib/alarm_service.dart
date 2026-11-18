import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmService {
  static final AlarmService instance = AlarmService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  AlarmService._init();

  Future<void> init() async {
    // إعدادات أندرويد لأيقونة الإشعارات
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // دالة لجدولة إشعار/تنبيه الدواء
  Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // سيتم ربطها بجدولة المواعيد الفعلية هنا
  }
}
