import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:home_widget/home_widget.dart';
import 'package:lord_bible/src/data/bible_data.dart';
import 'package:lord_bible/src/data/getChapterWord.dart';
import 'package:lord_bible/src/pages/bible_select.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/favorite_controller.dart';

class Bible extends StatefulWidget {
  const Bible({super.key});

  @override
  State<Bible> createState() => _BibleState();
}

final List<Color> additionalColors = [Colors.red, Colors.blue, Colors.green];

class _BibleState extends State<Bible> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  final List<String> versions = ["KJV흠정역", "KJV", "개역개정", "NIV"];
  List<String> selectedVersions = [];
  String? defaultVersion = "KJV흠정역";
  String? selectedBook = "Gen";
  String selectedChapter = "1";
  String selectedVerse = "1";
  List<Map<String, dynamic>> verses = [];
  Set<int> selectedIndexes = {};
  bool isLoading = false;
  int? idxOfVerse = 1;
  int? currentTileIndex = 0;

  final GlobalKey _listViewKey = GlobalKey();
  final GetChapterWord _getChapterWord = GetChapterWord();
  // final GetChapterWord2 _getChapterWord = GetChapterWord2();
  final ScrollController _scrollController = ScrollController();
  final FavoriteController favoriteController = Get.find<FavoriteController>();
  final Map<int, GlobalKey> keyMap = {};

  bool isDarkMode = false;

  String appGroupId = "group.com.Harim.Lordwords";
  String iOSWidgetName = "BibleWidget";

  @override
  void initState() {
    super.initState();
    _initializeTheme();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences().then((_) {
      selectedVersions.add(defaultVersion!);
      fetchVerses();
    });
    HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });

    if (state == AppLifecycleState.resumed) {
      _reloadData();
    }
  }

  void _reloadData() {
    _loadPreferences().then((_) {
      fetchVerses();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 다크 모드 상태를 감지하고 변경 시 업데이트
    final currentDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;
    if (currentDarkMode != isDarkMode) {
      setState(() {
        isDarkMode = currentDarkMode;
        fetchVerses();
      });
      return;
    }

    _loadPreferences().then((_) {
      fetchVerses();
    });
  }

  Future<void> _initializeTheme() async {
    setState(() {
      isDarkMode = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    });
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      defaultVersion = prefs.getString('defaultVersion') ?? "KJV흠정역";
      selectedBook = prefs.getString('selectedBook') ?? "Gen";
      selectedChapter = prefs.getString('selectedChapter') ?? "1";
      selectedVerse = prefs.getString('selectedVerse') ?? "1";
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultVersion', defaultVersion!);
    await prefs.setString('selectedBook', selectedBook!);
    await prefs.setString('selectedChapter', selectedChapter!);
  }

  Future<bool> _getAndSaveRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 기존데이터 불러오기
    List<String>? tmp = prefs.getStringList('readList');
    List<Map<String, String>> readList = [];
    if (tmp != null) {
      setState(() {
        readList = tmp.map((item) {
          List<String> parts = item.split(':');
          return {'address': parts[0], 'chapter': parts[1]};
        }).toList();
      });
    }

    bool isRead = readList.any(
          (e) => e['address'] == selectedBook && e['chapter'] == selectedChapter,
    );

    // 읽었다면 false, 아니면 data 수정
    if (isRead) {
      return false;
    } else {
      setState(() {
        prefs.setInt('readChapterCount', readList.length + 1);
        readList.add({'address': selectedBook!, 'chapter': selectedChapter});
        prefs.setStringList('readList', readList.map((e) => '${e['address']}:${e['chapter']}').toList());
      });
      return true;
    }
  }

  Future<void> fetchVerses() async {
    isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    if (selectedBook == null || selectedChapter == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // 기본 버전 데이터 부르기
      final defaultFetchedVerses = await _getChapterWord.fetchData(defaultVersion!, toLong['${selectedBook}']!, selectedChapter);

      // 선택된 추가 버전 데이터 가져옴
      Map<String, List<Map<String, String>>> additionVersionVerses = {};
      for (String version in selectedVersions) {
        if (version == defaultVersion) continue; // 기본 버전은 이미 가져옴
        final fetchedVerses = await _getChapterWord.fetchData(version, toLong['${selectedBook}']!, selectedChapter,);
        additionVersionVerses[version] = fetchedVerses;
      }

      // 교차 데이터
      List<Map<String, dynamic>> mergedVerses = [];
      for (int i = 0; i < defaultFetchedVerses.length; i++) {
        mergedVerses.add({
          'version': defaultVersion,
          'verse': defaultFetchedVerses[i]['verse'],
          'word': defaultFetchedVerses[i]['word'],
          'color': isDarkMode ? Colors.white : Colors.black,
        });

        // 추가 버전의 동일한 절 데이터 추가
        int versionIndex = 0;
        for (String version in selectedVersions) {
          if (version == defaultVersion) continue;
          final additionVerse = additionVersionVerses[version]?[i];
          if (additionVerse != null) {
            mergedVerses.add({
              'version': version,
              'verse': additionVerse['verse'],
              'word': additionVerse['word'],
              'color': additionalColors[versionIndex % additionalColors.length]
            });
            versionIndex++;
          }
        }
      }

      // keyMap 초기화
      final newKeyMap = <int, GlobalKey>{};
      for (int i = 0; i < mergedVerses.length; i++) {
        newKeyMap[i] = GlobalKey();
      }

      keyMap.clear(); // 기존 keyMap 초기화
      keyMap.addAll(newKeyMap);

      setState(() {
        verses = mergedVerses;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Loading...", backgroundColor: Colors.grey);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _saveFavoriteVerse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. 기존 favoriteWords 불러오기
    List<String> favoriteJson = prefs.getStringList('favoriteVerses') ?? [];
    List<Map<String, String>> existingFavorites = favoriteJson.map((jsonString) {
      return Map<String, String>.from(jsonDecode(jsonString));
    }).toList();

    if (selectedIndexes.length == 0) {
      return false;
    }

    // 2. 선택된 말씀 추가
    for (int index in selectedIndexes) {
      final verse = verses[index];
      Map<String, String> verseData = {
        "book": toLong[selectedBook]!,
        "chapter": selectedChapter,
        "verse": verse['verse'],
        "word": verse['word'],
      };

      // 중복 확인 후 추가
      bool isDuplicate = existingFavorites.any((fav) =>
      fav['book'] == verseData['book'] &&
          fav['chapter'] == verseData['chapter'] &&
          fav['verse'] == verseData['verse']);

      if (!isDuplicate) {
        existingFavorites.add(verseData);
      }
    }

    // 3. 업데이트된 데이터를 JSON으로 다시 저장
    List<String> updatedFavorites = existingFavorites.map((verse) {
      return jsonEncode(verse);
    }).toList();

    await prefs.setStringList('favoriteVerses', updatedFavorites);

    setState(() {
      selectedIndexes.clear();
    });

    favoriteController.refreshFavorites();
    return true;
  }

  Map<String, double> getListViewPosition() {
    final RenderBox? renderBox = _listViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero); // ListView의 시작점
      final height = renderBox.size.height; // ListView의 높이
      return {
        'start': position.dy,                // 시작점 y좌표
        'end': position.dy + height,         // 끝점 y좌표
      };
    }
    return {'start': 0.0, 'end': 0.0};
  }

  void toggleSelect(String version) {
    if (version == defaultVersion) return;

    Map<String, double> ListPosition = getListViewPosition();

    for (int index = 0; index < keyMap.length; index++) {
      final key = keyMap[index];
      if (key?.currentContext != null) {
        final RenderBox renderBox = key!.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = getListViewHeight();

        // 화면에 표시되고 있는 타일을 확인
        if (position.dy >= ListPosition['start']! && position.dy <= ListPosition['end']!) {
          currentTileIndex = index;
          break;
        }
      }
    }

    setState(() {
      if (selectedVersions.contains(version)) {
        currentTileIndex = ((currentTileIndex! + 1) / selectedVersions.length).toInt();
        selectedVersions.remove(version);
        fetchVerses().then((_) async {
          await Future.delayed(Duration(milliseconds: 300));
          currentTileIndex = ((currentTileIndex!)) * selectedVersions.length;
          scrollToVerse(currentTileIndex as num);
        });
      } else {
        currentTileIndex = (currentTileIndex! / selectedVersions.length).toInt();
        selectedVersions.add(version);
        fetchVerses().then((_) async {
          await Future.delayed(Duration(milliseconds: 300));
          currentTileIndex = ((currentTileIndex!)) * selectedVersions.length;
          scrollToVerse(currentTileIndex as num);
        });
      }
    });
  }

  double getListViewHeight() {
    final RenderBox? renderBox = _listViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.size.height;
    }
    return 0.0;
  }

  void _showMenu(BuildContext context) {
    showCupertinoModalPopup(context: context, builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: Text(tr("Menu"), style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white : Colors.black)),
        message: Text(tr("Choose an action")),
        actions: [
          CupertinoActionSheetAction(onPressed: () {
            Navigator.pop(context);
            if (_copySelectedItems()) {
              Fluttertoast.showToast(msg: tr("Copied"), backgroundColor: Colors.grey);
            } else {
              Fluttertoast.showToast(msg: tr("No items selected to copy"), backgroundColor: Colors.grey);
            }
          }, child: Text(tr("Copy"), style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white : Colors.black))),
          CupertinoActionSheetAction(onPressed: () async {
            Navigator.pop(context);
            if (await _saveFavoriteVerse()) {
              Fluttertoast.showToast(msg: tr("Added to favorites"), backgroundColor: Colors.grey);
            } else {
              Fluttertoast.showToast(msg: tr("No items selected to mark highlight"), backgroundColor: Colors.grey);
            }
          }, child: Text(tr("Highlight"), style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white : Colors.black))),
          CupertinoActionSheetAction(onPressed: () async {
            Navigator.pop(context);
            if (await _getAndSaveRead()) {
              Fluttertoast.showToast(msg: tr("Checked this chapter"), backgroundColor: Colors.grey);
            } else {
              Fluttertoast.showToast(msg: tr("Already checked"), backgroundColor: Colors.grey);
            }
          }, child: Text(tr("Read Check"), style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white : Colors.black))),
          CupertinoActionSheetAction(onPressed: () async {
            Navigator.pop(context);
            if (await updateWidget()) {
              Fluttertoast.showToast(msg: tr("Added to widget"), backgroundColor: Colors.grey);
            } else {
              Fluttertoast.showToast(msg: tr("Please check one verse"), backgroundColor: Colors.grey);
            }
          }, child: Text(tr("Put in widget"), style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white : Colors.black))),
        ],
      );
    });
  }

  bool _copySelectedItems() {
    if (selectedIndexes.isEmpty) {
      return false;
    }

    // 선택된 항목의 텍스트 결합
    String copiedText = selectedIndexes.map((index) {
      final verse = verses[index];
      return "${verse['verse']} ${verse['word']}";
    }).join("\n");

    // 클립보드에 복사
    Clipboard.setData(ClipboardData(text: "${tr(toLong[selectedBook]!)} ${selectedChapter}장 \n${copiedText}"));
    setState(() {
      selectedIndexes.clear();
    });

    return true;
  }

  Future<void> scrollToVerse(num index) async {
    if (keyMap.containsKey(index)) {
      final key = keyMap[index]!;
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: Duration(microseconds: 500),
      );
    } else {
      Fluttertoast.showToast(msg: "Key not found for index $index");
    }
  }

  Future<bool> updateWidget() async{
    if (selectedIndexes.length != 1) {
      return false;
    }

    String title = "";
    String description = "";

    for (int index in selectedIndexes) {
      final verse = verses[index];
      title = "${tr(toLong[selectedBook]!)} ${selectedChapter}:${verse['verse']}";
      description = "${verse['word']}";
    }

    setState(() {
      selectedIndexes.clear();
    });

    HomeWidget.saveWidgetData<String>('title', title);
    HomeWidget.saveWidgetData<String>('description', description);
    if (Platform.isIOS) {
      HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
      );
    } else if (Platform.isAndroid) {
      HomeWidget.updateWidget(
        qualifiedAndroidName: "com.ashjang.lordbible.lord_bible.BibleWidget",
        androidName: 'BibleWidget',
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Scaffold(
        appBar: CupertinoNavigationBar(
            heroTag: 'bible_tag',
            transitionBetweenRoutes: false,
            middle: Text(tr("Bible"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            leading: CupertinoButton(padding: EdgeInsets.zero, child: Text(tr("Menu"), style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white : Colors.black),), onPressed: () => _showMenu(context)),
            trailing: CupertinoButton(padding: EdgeInsets.all(0.0),
                child: Text(tr("Select"), style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white : Colors.black),),
                onPressed: () => {
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => BibleSelect()))
                      .then((result) async {
                    if (result != null) {
                      setState(() {
                        selectedBook = result['selectedBook'];
                        selectedChapter = result['selectedChapter'];
                        selectedVerse = result['selectedVerse'];
                        selectedIndexes.clear();
                      });
                      await _savePreferences();
                      fetchVerses().then((_) async {
                        await Future.delayed(Duration(milliseconds: 200));
                        scrollToVerse((int.parse(selectedVerse) - 1) * selectedVersions.length);
                      });
                    }
                  })
                }),
            backgroundColor: Colors.transparent,
            border: Border(bottom: BorderSide(color: Colors.transparent))
        ),

        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 버전 선택
                _versionButton(),
                // 주소 선택(이전,이후)
                _addressBefAf(),
                // 순서
                _orderVersion(),
                // 리스트
                _verseList(),
              ],
            ),

            if (isLoading)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false, // 터치 이벤트 전달 허용
                  child: Container(
                    color: Colors.black45.withOpacity(0.5), // 반투명 배경
                    child: Center(
                      child: CupertinoActivityIndicator(
                        radius: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        )
    );
  }

  // version button
  Widget _versionButton() {
    double fontSize = MediaQuery.of(context).size.width * 0.038;

    return Scrollbar(
      thumbVisibility: false,
      thickness: 4,
      radius: const Radius.circular(10),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: 6),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: versions.map((version) {
            bool isSelected = selectedVersions.contains(version);
            bool isDefault = version == defaultVersion;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => toggleSelect(version),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDefault
                        ? Colors.grey[500]
                        : isSelected
                        ? Colors.grey[500]
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    version,
                    style: TextStyle(
                      color: isDefault
                          ? Colors.black
                          : isSelected
                          ? Colors.white
                          : Colors.grey[500],
                      fontWeight: isDefault
                          ? FontWeight.bold
                          : isSelected
                          ? FontWeight.normal
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 말씀구절 라벨 및 이전,다음 버튼
  Widget _addressBefAf() {
    return Container (
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (int.tryParse(selectedChapter)! != 1)
                ? () {
              _savePreferences();
              setState(() {
                selectedIndexes.clear();
                selectedChapter =
                    (int.tryParse(selectedChapter)! - 1).toString();
                fetchVerses();
                scrollToVerse(0);
              });
            } : null,
            child: SizedBox(
              height: 40,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.navigate_before,
                  size: 30, // 아이콘 크기 조절
                  color: int.tryParse(selectedChapter)! != 1
                      ? (isDarkMode ? Colors.white : Colors.black)
                      : Colors.grey,
                ),
              ),
            ),
          ),
          Text(
            selectedBook != null && selectedChapter != null
                ? "${tr(toLong[selectedBook]!)} $selectedChapter"
                : "",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: (int.tryParse(selectedChapter)! != bibleData[selectedBook])
                ? () {
              _savePreferences();
              setState(() {
                selectedIndexes.clear();
                selectedChapter =
                    (int.tryParse(selectedChapter)! + 1).toString();
                fetchVerses();
                scrollToVerse(0);
              });
            } : null,
            child: SizedBox(
              height: 40,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.navigate_next,
                  size: 30,
                  color: int.tryParse(selectedChapter)! != bibleData[selectedBook]
                      ? (isDarkMode ? Colors.white : Colors.black)
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderVersion() {
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Text("order: ${selectedVersions}", style: TextStyle(color: Colors.grey[500], fontSize: 12,),),)
    );
  }

  Widget _verseList() {
    if (verses.isEmpty) {
      return Center();
    }

    return Expanded(
        child: Scrollbar(
          thumbVisibility: true,
          interactive: true,
          thickness: 5.0,
          radius: Radius.circular(10.0),
          controller: _scrollController,
          child: ListView.separated(
            key: _listViewKey,
            cacheExtent: 100000,
            controller: _scrollController,
            itemCount: verses.length,
            separatorBuilder: (context, index) {
              // 현재 구절과 다음 구절의 절 번호 비교
              final currentVerse = verses[index]['verse'];
              final nextVerse = index + 1 < verses.length ? verses[index + 1]['verse'] : null;

              // 새로운 절의 시작 여부를 판단
              if (nextVerse != null && currentVerse != nextVerse) {
                // 새로운 절 시작: 두꺼운 구분선
                return Divider(
                  color: Colors.grey[700],
                  thickness: 0.8,
                  height: 1.0,
                );
              } else {
                // 같은 절 내의 구분: 얇은 구분선
                return Divider(
                  color: Colors.grey,
                  thickness: 0.3,
                  height: 1.0,
                );
              }
            },
            itemBuilder: (context, index) {
              final verse = verses[index];
              final isSelected = selectedIndexes.contains(index);

              return ListTile(
                key: keyMap[index],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18, // 좌우 패딩 유지
                  vertical: 0,    // 위아래 패딩 최소화 (필요에 따라 조정)
                ),
                tileColor: isSelected ? (isDarkMode ? Colors.white24 : Colors.grey[350]) : null,
                title: Text("${verse['verse']}  ${verse['word']}",
                  style: TextStyle(height: 1.3, color: verse['color'],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedIndexes.remove(index);
                      selectedIndexes.toList().sort();
                    } else {
                      selectedIndexes.add(index); // 새로 선택
                      selectedIndexes.toList().sort();
                    }
                  });
                },
              );
            },
          ),
        )
    );
  }
}