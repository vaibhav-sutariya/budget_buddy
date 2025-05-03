import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        selectNotification(notificationResponse.payload);
      },
    );

    final prefs = await SharedPreferences.getInstance();

    bool? isAllowed = prefs.getBool("isReminderAllowed") ?? true;

    if (isAllowed == true) {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("tokenOfLoggedInUser") ?? "";
      if (token.isNotEmpty) {
        //only schedule notification if user is logged in
        await scheduleDailyEightPMNotification();
      }
    }
  }

  Future<void> showNotifications({id, title, body, payload}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleDailyEightPMNotification() async {
    //DateTime dateTime = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,11);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      "Don't forget to record your expenses !",
      "Click to add one.",
      //tz.TZDateTime.from(dateTime, tz.local),
      _nextInstanceOfEightPM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily notification channel id',
          'daily notification channel name',
          channelDescription: 'daily notification description',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // This is safer
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstanceOfEightPM() {
    DateTime dateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      20,
    );

    tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    if (scheduledDate.isBefore(dateTime)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future selectNotification(String? payload) async {
    //Handle notification tapped logic here
    //print(payload);
    Get.to(const HomeScreen());
  }
}
