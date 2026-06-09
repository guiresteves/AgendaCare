import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;


    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Maceio'));

    const android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: android,
    );

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notifications',
          'Notificações Instantâneas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleTaskNotifications({
    required int taskId,
    required String title,
    required String description,
    required DateTime taskDateTime,
  }) async {
    final now = DateTime.now();

    final tenMinutesBefore = taskDateTime.subtract(
      const Duration(minutes: 10),
    );

    if (tenMinutesBefore.isAfter(now)) {
      await _plugin.zonedSchedule(
        taskId,
        'Tarefa próxima',
        'Faltam 10 minutos para: $title',
        tz.TZDateTime.from(tenMinutesBefore, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Lembretes de tarefas',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,      );
    }

    if (taskDateTime.isAfter(now)) {
      await _plugin.zonedSchedule(
        taskId + 100000,
        'Hora da tarefa',
        title,
        tz.TZDateTime.from(taskDateTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_due',
            'Tarefas vencendo',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,      );
    }
  }

  Future<void> cancelTaskNotifications(int taskId) async {
    await _plugin.cancel(taskId);
    await _plugin.cancel(taskId + 100000);
  }
}