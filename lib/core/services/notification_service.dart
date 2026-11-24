import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Request Android 13+ Notification Permission
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  NotificationDetails _highPriorityDetails() {
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'care_circle_high_v4', // New channel to clear cache
        'Care Circle Reminders',
        channelDescription: 'High priority care and medicine alarms',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final safeId = id.abs() % 2147483647;
    await _notificationsPlugin.show(
      safeId,
      title,
      body,
      _highPriorityDetails(),
    );
  }




  /// Schedule daily repeating reminder for medication
  Future<void> scheduleDailyMedicationReminder({
    required int id,
    required String medicineName,
    required String dosage,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final safeId = id.abs() % 2147483647;

    await _notificationsPlugin.zonedSchedule(
      safeId,
      'Time for Medicine: $medicineName 💊',
      'Scheduled dosage: $dosage',
      scheduledDate,
      _highPriorityDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 🩺 Schedule reminder for a Doctor Appointment date & time
  Future<void> scheduleAppointmentReminder({
    required int id,
    required String doctorName,
    required String clinic,
    required DateTime appointmentDateTime,
  }) async {
    final scheduledDate = tz.TZDateTime.from(appointmentDateTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isAfter(now)) {
      final safeId = id.abs() % 2147483647;
      await _notificationsPlugin.zonedSchedule(
        safeId,
        'Doctor Visit: $doctorName 🩺',
        'Appointment at $clinic at ${appointmentDateTime.hour.toString().padLeft(2, '0')}:${appointmentDateTime.minute.toString().padLeft(2, '0')}',
        scheduledDate,
        _highPriorityDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// ✅ Schedule reminder for a Daily Care Task due date & time
  Future<void> scheduleTaskReminder({
    required int id,
    required String taskTitle,
    required String assigneeName,
    required DateTime dueDateTime,
  }) async {
    final scheduledDate = tz.TZDateTime.from(dueDateTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isAfter(now)) {
      final safeId = id.abs() % 2147483647;
      await _notificationsPlugin.zonedSchedule(
        safeId,
        'Care Task Due: $taskTitle ✅',
        'Assigned to $assigneeName at ${dueDateTime.hour.toString().padLeft(2, '0')}:${dueDateTime.minute.toString().padLeft(2, '0')}',
        scheduledDate,
        _highPriorityDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    final safeId = id.abs() % 2147483647;
    await _notificationsPlugin.cancel(safeId);
  }
}