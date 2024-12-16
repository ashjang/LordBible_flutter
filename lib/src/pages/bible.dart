import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lord_bible/src/data/bible_data.dart';
import 'package:lord_bible/src/data/getChapterWord.dart';
import 'package:lord_bible/src/pages/bible_select.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bible extends StatefulWidget {
  const Bible({super.key});

  @override
  State<Bible> createState() => _BibleState();
}

final List<Color> additionalColors = [Colors.red, Colors.blue, Colors.green];

class _BibleState extends State<Bible> {
  final List<String> versions = ["KJV흠정역", "KJV", "개역개정", "NIV"];
  List<String> selectedVersions = [];
  String? defaultVersion = "KJV흠정역";
  String? selectedBook = "Gen";
  String selectedChapter = "1";
  List<Map<String, dynamic>> verses = [];
  Set<int> selectedIndexes = {};
  bool isLoading = false;
  final GetChapterWord _getChapterWord = GetChapterWord();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedVersions.add(versions[0]);
    _loadPreferences();
    fetchVerses();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      defaultVersion = prefs.getString('defaultVersion') ?? "KJV흠정역";
      selectedBook = prefs.getString('selectedBook') ?? "Gen";
      selectedChapter = prefs.getString('selectedChapter') ?? "1";
    });
    fetchVerses();
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultVersion', defaultVersion!);
    await prefs.setString('selectedBook', selectedBook!);
    await prefs.setString('selectedChapter', selectedChapter!);
  }

  Future<void> fetchVerses() async {
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
          'color': Colors.black,
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

      setState(() {
        verses = mergedVerses;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleSelect(String version) {
    setState(() {
      if (version == versions[0]) return;

      if (selectedVersions.contains(version)) {
        selectedVersions.remove(version);
      } else {
        selectedVersions.add(version);
      }

      fetchVerses();
    });
  }

  void _showMenu(BuildContext context) {
    showCupertinoModalPopup(context: context, builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: Text("Menu"),
        message: Text("Choose an action"),
        actions: [
          CupertinoActionSheetAction(onPressed: () {
            Navigator.pop(context);
            _copySelectedItems();
            Fluttertoast.showToast(msg: "Copied");
          }, child: Text("Copy")),
          CupertinoActionSheetAction(onPressed: () {
            Navigator.pop(context);
            Fluttertoast.showToast(msg: "Added to favorites");
          }, child: Text("Highlight")),
          CupertinoActionSheetAction(onPressed: () {
            Navigator.pop(context);
            Fluttertoast.showToast(msg: "Checked this chapter");
          }, child: Text("Read Check")),
          CupertinoActionSheetAction(onPressed: () {
            Navigator.pop(context);
            Fluttertoast.showToast(msg: "Added to widget");
          }, child: Text("Put in widget")),
        ],
      );
    });
  }

  void _copySelectedItems() {
    if (selectedIndexes.isEmpty) {
      Fluttertoast.showToast(msg: "No items selected to copy.");
      return;
    }

    // 선택된 항목의 텍스트 결합
    String copiedText = selectedIndexes.map((index) {
      final verse = verses[index];
      return "${verse['verse']} ${verse['word']}";
    }).join("\n");

    // 클립보드에 복사
    Clipboard.setData(ClipboardData(text: "${toLong[selectedBook]} ${selectedChapter}장\n${copiedText}"));
    setState(() {
      selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
            heroTag: 'bible_tag',
            transitionBetweenRoutes: false,
            middle: Text("Bible", style: TextStyle(fontWeight: FontWeight.bold)),
            leading: CupertinoButton(padding: EdgeInsets.zero, child: Text("Menu", style: TextStyle(fontSize: 18.0),), onPressed: () => _showMenu(context)),
            trailing: CupertinoButton(padding: EdgeInsets.all(0.0),
              child: Text("Select", style: TextStyle(fontSize: 18.0),),
              onPressed: () => {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => BibleSelect()))
                .then((result) async {
                  if (result != null) {
                    setState(() {
                      selectedBook = result['selectedBook'];
                      selectedChapter = result['selectedChapter'];
                      selectedIndexes.clear();
                    });
                    await _savePreferences();
                    fetchVerses().then((_) {
                      _scrollController.jumpTo(0);
                    });
                  }
                })
              }),
            backgroundColor: Colors.transparent,
            border: Border(bottom: BorderSide(color: Colors.transparent))
        ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 버전 선택
          _versionButton(),
          // 주소 선택(이전,이후)
          _addressBefAf(),
          // 순서
          _orderVersion(),
          // SizedBox(height: 5,),
          // 리스트
          _verseList(),
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
            bool isDefault = version == versions[0];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => toggleSelect(version),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 10),
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
                      fontSize: fontSize,
                      color: isDefault
                          ? Colors.black
                          : isSelected
                          ? Colors.white
                          : Colors.grey[500],
                      fontWeight: isDefault
                          ? FontWeight.bold
                          : isSelected
                          ? FontWeight.bold
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CupertinoButton(child: Icon(Icons.navigate_before, size: 30,),
            onPressed: () {
              selectedChapter = (int.tryParse(selectedChapter)! - 1).toString();
              fetchVerses();
            }),
        Text(selectedBook != null && selectedChapter != null
            ? "${toLong['${selectedBook}']}  $selectedChapter"
            : "", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
        CupertinoButton(child: Icon(Icons.navigate_next, size: 30),
            onPressed: () {
              selectedChapter = (int.tryParse(selectedChapter)! + 1).toString();
              fetchVerses();
            }),
      ],
    );
  }

  Widget _orderVersion() {
    double fontSize = MediaQuery.of(context).size.width * 0.037;
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Text("order: ${selectedVersions}", style: TextStyle(color: Colors.grey[500], fontSize: fontSize,),),)
    );
  }

  Widget _verseList() {
    if (isLoading) {
      return Expanded(child: Center(child: CupertinoActivityIndicator(radius: 20.0, color: Colors.grey),));
    }

    if (verses.isEmpty) {
      return Center(child: Text("No verses available"));
    }

    return Expanded(
      child: ListView.separated(
        controller: _scrollController,
        itemCount: verses.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey,
          thickness: 1,
          height: 0,
        ),
        itemBuilder: (context, index) {
          final verse = verses[index];
          final isSelected = selectedIndexes.contains(index);

          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18, // 좌우 패딩 유지
              vertical: 0,    // 위아래 패딩 최소화 (필요에 따라 조정)
            ),
            tileColor: isSelected ? Colors.grey : null,
            title: Text("${verse['verse']}  ${verse['word']}", style: TextStyle(height: 1.3, color: verse['color'] ?? Colors.black),),
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
    );
  }
}