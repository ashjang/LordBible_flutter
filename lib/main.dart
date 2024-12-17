import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lord_bible/firebase_options.dart';
import 'package:lord_bible/src/app.dart';
import 'package:lord_bible/src/binding/init_binding.dart';
import 'package:lord_bible/src/controller/favorite_controller.dart';
import 'package:lord_bible/src/controller/scale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(FavoriteController());
  Get.lazyPut(()=>TextScaleController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final TextScaleController textScaleController = Get.find();

    return GetMaterialApp(
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
