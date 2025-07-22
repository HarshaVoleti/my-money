import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS =
        DarwinInitializationSettings(
      
    );

    const initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Request permissions for iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request permissions for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'finance_tracker',
      'Finance Tracker',
      channelDescription: 'Notifications for finance tracking reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'finance_tracker_scheduled',
      'Finance Tracker Scheduled',
      channelDescription: 'Scheduled notifications for finance reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    const androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'finance_tracker_repeating',
      'Finance Tracker Repeating',
      channelDescription: 'Repeating notifications for finance reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // await flutterLocalNotificationsPlugin.periodicallyShow(
    //   id,
    //   title,
    //   body,
    //   repeatInterval,
    //   platformChannelSpecifics,
    //   payload: payload,
    // );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // EMI Reminder Notifications
  Future<void> scheduleEmiReminder({
    required String emiId,
    required String title,
    required DateTime dueDate,
    required int daysBefore,
    required double amount,
  }) async {
    final reminderDate = dueDate.subtract(Duration(days: daysBefore));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: emiId.hashCode,
        title: '💰 EMI Reminder',
        body: '$title - ₹${amount.toStringAsFixed(0)} due in $daysBefore days',
        scheduledDate: reminderDate,
        payload: 'emi:$emiId',
      );
    }
  }

  // Borrow/Lend Reminder Notifications
  Future<void> scheduleBorrowLendReminder({
    required String borrowLendId,
    required String personName,
    required String type,
    required DateTime dueDate,
    required double amount,
  }) async {
    final reminderDate = dueDate.subtract(const Duration(days: 1));

    if (reminderDate.isAfter(DateTime.now())) {
      final actionText = type == 'borrowed' ? 'return' : 'collect';
      await scheduleNotification(
        id: borrowLendId.hashCode,
        title: '🤝 Payment Reminder',
        body:
            'Remember to $actionText ₹${amount.toStringAsFixed(0)} from/to $personName tomorrow',
        scheduledDate: reminderDate,
        payload: 'borrow_lend:$borrowLendId',
      );
    }
  }

  // Investment Tracking Notifications (Weekly summary)
  Future<void> scheduleInvestmentSummary() async {
    await scheduleRepeatingNotification(
      id: 'investment_summary'.hashCode,
      title: '📈 Weekly Investment Summary',
      body: 'Check your portfolio performance this week',
      repeatInterval: RepeatInterval.weekly,
      payload: 'investment_summary',
    );
  }

  // Helper method to convert DateTime to TZDateTime
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) => 
      tz.TZDateTime.from(dateTime, tz.local);
}
