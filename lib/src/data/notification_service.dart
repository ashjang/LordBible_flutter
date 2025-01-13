import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {
  static Future<void> onDidReciveNotification(NotificationResponse res) async {

  }

  // 초기화
  static Future<void> init() async {
    // tz.initializeTimeZones();

    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      onDidReceiveNotificationResponse: onDidReciveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReciveNotification
    );

    await requestNotificationPermission();
  }

  static requestNotificationPermission() {
    final Completer<void> permissionCompleter = Completer<void>();

    // Android 알림 권한 요청
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission().then((granted) {
      log("Android 권한 결과: $granted");
      permissionCompleter.complete();       // 결과에 상관없이 완료 처리
    });

    // iOS 알림 권한 요청
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    )
        .then((granted) {
      log("iOS 권한 결과: $granted");
      permissionCompleter.complete();       // 결과에 상관없이 완료 처리
    });

    // 사용자가 선택할 때까지 대기
    return permissionCompleter.future;
  }

  // 권한 확인
  static Future<bool> _checkPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    } else {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
  }

  static Future<bool> scheduleDayNotifications(DateTime now) async {
    if (!await _checkPermission() || DateTime.now().isAfter(DateTime.now().copyWith(hour: 8, minute: 30))) {
      // flutterLocalNotificationsPlugin.cancel(1);
      log("check permission or wrong time");
      return false;
    }
    await scheduleNotification(1, 'morning', '8시 30분에 보내는 알림', now);
    return true;
  }

  static Future<bool> scheduleNightNotifications(DateTime now) async {
    if (!await _checkPermission() || DateTime.now().isAfter(DateTime.now().copyWith(hour: 22, minute: 0))) {
      // flutterLocalNotificationsPlugin.cancel(2);
      log("check permission or wrong time");
      return false;
    }
    await scheduleNotification(2, 'night', '10시에 보내는 알림', now);
    return true;
  }

  static void showBasicNotification() async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'daily_notifications',
      'Daily Notifications',
      channelDescription: 'This channel is for daily notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    final DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    
    await flutterLocalNotificationsPlugin.show(0, 'Basic notification', 'body', notificationDetails);
  }

  // 알림 생성 및 스케줄링
  static Future<void> scheduleNotification(int id, String title, String body, DateTime dateTime) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'daily_notifications',
      'Daily Notifications',
      channelDescription: 'This channel is for daily notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    final DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    var scheduleTime = tz.TZDateTime(
        tz.local,
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute
    );

    Map<String, dynamic> data = await getData(scheduleTime.month - 1, scheduleTime.day);
    print("${tr(data['address'])} ${data['chapter']}:${data['verse']}");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      "${tr(data['address'])} ${data['chapter']}:${data['verse']}",
      "${data['word']}",
      scheduleTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time
    );
  }

  static Future<Map<String, dynamic>> getData(int month, int day) async {
    final FirebaseDatabase db = FirebaseDatabase.instance;

    try {
      DatabaseReference ref = db.ref().child('randomWord').child('KJV흠정역').child('$month').child('$day');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        // Safely cast the snapshot value to a Map
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        log("[Firebase] No data found for the specified date.");
        return {};
      }
    } catch (e, stackTrace) {
      log("Error $e");
      log("Stack trace: $stackTrace");
      return {};
    }
  }
}