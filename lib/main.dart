import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lord_bible/src/app.dart';
import 'package:lord_bible/src/binding/init_binding.dart';
import 'package:lord_bible/src/controller/favorite_controller.dart';
import 'package:lord_bible/src/controller/scale_controller.dart';
import 'package:lord_bible/src/data/notification_service.dart';
import 'package:lord_bible/src/data/workmanager_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    NotificationService.init(),
    if (Platform.isAndroid) WorkManagerService().init()
  ]);

  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  if (Platform.isIOS) {
    await NotificationService.scheduleDayNotifications(DateTime.now().copyWith(hour: 8, minute: 30));
    await NotificationService.scheduleNightNotifications(DateTime.now().copyWith(hour: 22, minute: 0));
  }

  Timer.periodic(Duration(minutes: 1), (timer) async {
    if (Platform.isIOS) {
      await NotificationService.scheduleDayNotifications(DateTime.now().copyWith(hour: 8, minute: 30));
      await NotificationService.scheduleNightNotifications(DateTime.now().copyWith(hour: 22, minute: 0));
    }
  });

  Get.put(FavoriteController());
  Get.lazyPut(()=>TextScaleController());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
        path: 'assets/translations',
        // fallbackLocale: const Locale('en', 'US'),
        child: MyApp(isDarkMode: isDarkMode),
      )
    );
  });
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final TextScaleController textScaleController = Get.find();

    Future.wait([
      NotificationService.init(),
      WorkManagerService().init(),
    ]);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      initialBinding: InitBinding(),
      builder: (context, child) {
        return Obx(() {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: textScaleController.textScale.value, // 실시간 반영
            ),
            child: child!,
          );
        });
      },
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const App(),
    );
  }
}