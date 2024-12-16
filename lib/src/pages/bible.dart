import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lord_bible/src/data/bible_data.dart';
import 'package:lord_bible/src/data/getChapterWord.dart';
import 'package:lord_bible/src/pages/bible_select.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class Bible extends StatefulWidget {
  const Bible({super.key});

  @override
  State<Bible> createState() => _BibleState();
}

class _BibleState extends State<Bible> {
  final List<String> versions = ["KJV흠정역", "KJV", "개역개정", "NIV"];
  List<String> selectedVersions = [];
  String? selectedBook = "Gen";
  String selectedChapter = "1";
  List<Map<String, String>> verses = [];
  Set<int> selectedIndexes = {};
  final GetChapterWord _getChapterWord = GetChapterWord();

  @override
  void initState() {
    super.initState();
    selectedVersions.add(versions[0]);
    fetchVerses();
  }

  Future<void> fetchVerses() async {
    if (selectedBook == null || selectedChapter == null) return;

    try {
      final fetchedVerses = await _getChapterWord.fetchData("KJV흠정역", toLong['${selectedBook}']!, selectedChapter);
      setState(() {
        verses = fetchedVerses;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load data: $e");
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
                .then((result) {
                  if (result != null) {
                    setState(() {
                      selectedBook = result['selectedBook'];
                      selectedChapter = result['selectedChapter'];
                    });
                    fetchVerses();
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
          // 리스트
          const SizedBox(height: 20),
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
          child: Text("order: ${selectedVersions}", style: TextStyle(color: Colors.grey[500], fontSize: fontSize, height: 0.01),),)
    );
  }

  Widget _verseList() {
    if (verses.isEmpty) {
      return Center(child: Text("No verses available"));
    }
    return Expanded(
      child: ListView.separated(
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
            title: Text("${verse['verse']}  ${verse['word']}", style: TextStyle(height: 1.3,),),
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