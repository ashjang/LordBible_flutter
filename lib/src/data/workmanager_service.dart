import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:lord_bible/src/data/notification_service.dart';
import 'package:workmanager/workmanager.dart';

class WorkManagerService {
  Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  Future<void> register() async {
    await Workmanager().registerPeriodicTask(
      'morning',
      'morning',
      frequency: const Duration(minutes: 15),
      tag: 'dailyTasks',
    );

    await Workmanager().registerPeriodicTask(
      'night',
      'night',
      frequency: const Duration(minutes: 15),
      tag: 'dailyTasks',
    );
  }

  void cancelTask(String id) {
    Workmanager().cancelByUniqueName(id);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {


  Workmanager().executeTask((taskName, inputData) async {
    try {
      await Firebase.initializeApp();
      log("Firebase initialized successfully in background");
    } catch (e) {
      log("Firebase initialization error: $e");
      return Future.value(false);
    }

    if (taskName == "morning") {
      await NotificationService.scheduleDayNotifications(DateTime.now().copyWith(hour: 8, minute: 30));
    } else if (taskName == "night") {
      await NotificationService.scheduleNightNotifications(DateTime.now().copyWith(hour: 22, minute: 0));
    }

    return Future.value(true);
  });
}