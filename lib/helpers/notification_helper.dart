// lib/helpers/notification_helper.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/class_event_model.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Agenda uma notificação específica para uma aula, para a noite anterior
  Future<void> scheduleNotificationForClass(ClassEvent event) async {
    // A notificação será agendada para as 20h (8 PM) do dia anterior à aula.
    final notificationTime = tz.TZDateTime(tz.local, event.date.year, event.date.month, event.date.day - 1, 20);

    // Garante que não estamos agendando uma notificação no passado.
    if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      event.id!, // Usa o ID do evento como ID da notificação para poder cancelá-la depois
      'Lembrete de Aula Amanhã',
      'Aula às ${event.time} com ${event.studentNames}. Não se esqueça de avisá-los!',
      notificationTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_notification_channel_id',
          'Class Reminder Notifications',
          channelDescription: 'Notificações para lembrar de aulas agendadas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancela uma notificação agendada usando o ID do evento
  Future<void> cancelNotificationForClass(int eventId) async {
    await _notificationsPlugin.cancel(eventId);
  }
}
