import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:lord_bible/src/controller/favorite_controller.dart';
import 'package:lord_bible/src/data/bible_data.dart';
import 'package:lord_bible/src/data/getRandomWord.dart';
import 'package:lord_bible/src/data/notification_service.dart';
import 'package:lord_bible/src/data/workmanager_service.dart';
import 'package:lord_bible/src/pages/favorite_select.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AppLifecycleState? _lastLifecycleState;
  List<Map<String, String>> favoriteWords = [];
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
    _loadFavoriteWords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavoriteWords();
  }

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   setState(() {
  //     _lastLifecycleState = state;
  //   });
  //
  //   if (state == AppLifecycleState.resumed) {
  //     if (Platform.isIOS) {
  //       await NotificationService.scheduleDayNotifications(DateTime.now().copyWith(hour: 8, minute: 30));
  //       await NotificationService.scheduleNightNotifications(DateTime.now().copyWith(hour: 22, minute: 0));
  //     }
  //   }
  // }

  void _checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      log("isFirstRun true");
      prefs.setBool('isFirstRun', false);
      if (Platform.isAndroid) {
        await WorkManagerService().register();
      }
    }
  }

  Future<void> _loadFavoriteWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteJson = prefs.getStringList('favoriteVerses') ?? [];

    setState(() {
      favoriteWords = favoriteJson.map((jsonString) {
        return Map<String, String>.from(jsonDecode(jsonString));
      }).toList();
    });
  }

  Future<void> _saveFavoriteWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatedFavorites = favoriteWords.map((word) {
      return jsonEncode(word);
    }).toList();
    await prefs.setStringList('favoriteVerses', updatedFavorites);
  }

  Widget _todayWord() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.book_fill, color: Colors.grey[600]),
            SizedBox(width: 5),
            Text(tr("Today's word"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0)),
          ],
        ),
        SizedBox(height: 6),
        GetRandomWord(),
        SizedBox(height: 30),
      ]
    );
  }

  Widget _favoriteWord() {
    return Expanded(child:
    Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.065, // 좌우 여백 5%
      ),
      child: Scrollbar(
        thumbVisibility: false,
        thickness: 5.0,
        radius: Radius.circular(10.0),
        child: favoriteWords.isEmpty ? Center()
            : ListView.separated(
          shrinkWrap: true,
          itemCount: favoriteWords.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey,
            thickness: 0.8,
            height: 1.0,
          ),
          itemBuilder: (context, index) {
            final word = favoriteWords[index];
            return Dismissible(
              key: Key(word.toString()), // 고유 키 사용
              direction: DismissDirection.endToStart, // 왼쪽에서 오른쪽 슬라이드
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white, size: 30),
              ),
              onDismissed: (direction) {
                setState(() {
                  favoriteWords.removeAt(index);
                  _saveFavoriteWords();
                });
                Fluttertoast.showToast(msg: tr("Deleted from favorite words"), backgroundColor: Colors.grey);
              },
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                title: Text(
                  "${tr("ShortNames.${toShort[word['book']!]!}")} ${word['chapter']}:${word['verse']}   ${word['word']}",
                  style: TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                onTap: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => FavoriteSelect(word: word,)));
                },
              ),
            );
          },
        ),
      ),
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Obx(() {
      favoriteController.favoriteRefreshKey.value;
      _loadFavoriteWords();
      return Scaffold(
          appBar: CupertinoNavigationBar(
              middle: Text(tr("Home"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
              backgroundColor: Colors.transparent,
              border: Border(bottom: BorderSide(color: Colors.transparent))
          ),

          body: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      _todayWord(),
                      SizedBox(height: 20),

                    ],
                  )
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.star_fill, color: Colors.yellow,),
                    SizedBox(width: 5),
                    Text(tr("Favorite words"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0)),
                    SizedBox(width: 6),
                  ],
                ),
              ),
              _favoriteWord(),
            ],
          )
      );
    });
  }
}
