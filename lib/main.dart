import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lord_bible/src/app.dart';
import 'package:lord_bible/src/binding/init_binding.dart';
import 'package:lord_bible/src/controller/favorite_controller.dart';
import 'package:lord_bible/src/controller/scale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  // 권한 요청 처리
  bool isPermissionGranted = await _ensureNotificationPermission();

  if (!isPermissionGranted) {
    // 권한이 거부된 경우 경고 화면 표시
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              'Notification permissions are required to use this app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
    return; // 앱 초기화 중지
  }

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

Future<bool> _ensureNotificationPermission() async {
  // 권한 요청 결과를 대기
  while (true) {
    var status = await Permission.notification.status;

    // 권한이 부여된 경우 true 반환
    if (status.isGranted) return true;

    // 권한이 거부된 경우 권한 요청 반복
    if (status.isDenied) {
      await Permission.notification.request();
    }

    // 권한 요청이 "사용자가 다시 묻지 않음"으로 설정된 경우 종료
    if (status.isPermanentlyDenied) {
      return false; // 권한 요청 불가
    }

    // 대기 상태 유지
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final TextScaleController textScaleController = Get.find();

    return GetMaterialApp(
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