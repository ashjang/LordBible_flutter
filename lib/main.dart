import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lord_bible/firebase_options.dart';
import 'package:lord_bible/src/app.dart';
import 'package:lord_bible/src/binding/init_binding.dart';
import 'package:lord_bible/src/controller/favorite_controller.dart';
import 'package:lord_bible/src/controller/scale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  Get.put(FavoriteController());
  Get.lazyPut(()=>TextScaleController());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR'), Locale('en_long', 'US'), Locale('ko_long', 'KR')],
        path: 'assets/translations',
        // fallbackLocale: const Locale('en', 'US'),
        child: MyApp(),
      )
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
      home: const App(),
    );
  }
}