import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadCheckChapter extends StatefulWidget {
  final String? selectedBook;
  final int chapterCount;
  final String? selectedChapter;
  final ValueChanged<String> onChapterSelected;

  const ReadCheckChapter({
    super.key,
    required this.selectedBook,
    required this.chapterCount,
    required this.selectedChapter,
    required this.onChapterSelected
  });

  @override
  State<ReadCheckChapter> createState() => _ReadCheckChapterState();
}

class _ReadCheckChapterState extends State<ReadCheckChapter> {
  final int allChapter = 1189;
  List<Map<String, String>> readList = [];
  bool isLoading = true;
  bool isChapterRead = false;

  @override
  void initState() {
    super.initState();
    _getRead();
  }

  Future<void> _saveRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('readList', readList.map((e) => '${e['address']}:${e['chapter']}').toList());

    // 현재 장을 읽었다면 +1, 외엔 -1
    int currentChapter = await _getReadChapterCount();
    if (!isChapterRead) {
      prefs.setInt('readChapterCount', currentChapter - 1);
    } else {
      prefs.setInt('readChapterCount', currentChapter + 1);
      isChapterRead = false;
    }

    if (currentChapter > (allChapter - 2)) {
      prefs.setInt('readCount', await _getReadCount() + 1);
      readList.clear();
      prefs.setStringList('readList', readList.map((e) => '${e['address']}:${e['chapter']}').toList());
      prefs.setInt('readChapterCount', 0);
    }
  }

  Future<int> _getReadChapterCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('readChapterCount') ?? 0;
  }

  Future<int> _getReadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('readCount') ?? 0;
  }

  Future<void> _getRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tmp = prefs.getStringList('readList');
    if (tmp != null) {
      setState(() {
        readList = tmp.map((item) {
          List<String> parts = item.split(':');
          return {'address': parts[0], 'chapter': parts[1]};
        }).toList();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void updateReadList(String chapter) {
    setState(() {
      final existingIdx = readList.indexWhere((e) =>
      e['address'] == widget.selectedBook && e['chapter'] == chapter);
      if (existingIdx >= 0) {
        isChapterRead = false;
        readList.removeAt(existingIdx);
      } else {
        isChapterRead = true;
        readList.add({"address": widget.selectedBook!, "chapter": chapter});
      }
      _saveRead();
    });

    widget.onChapterSelected(chapter);
  }

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    int crossAxisCount = textScaleFactor > 1.3 ? 5 : 6;
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    if (widget.selectedBook == null) {
      return Center(child: Text(tr("Please choose book first")));
    }

    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 20.0, color: Colors.grey),);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: widget.chapterCount,
                itemBuilder: (context, index) {
                  String chapter = (index + 1).toString();
                  _getRead();
                  bool isRead = readList.any(
                        (e) => e['address'] == widget.selectedBook && e['chapter'] == chapter,
                  );

                  return GestureDetector(
                    onTap: () => updateReadList(chapter),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isRead
                            ? (isDarkMode ? Colors.white30 : CupertinoColors.systemFill.withOpacity(0.6))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isDarkMode ? Colors.white30 : CupertinoColors.systemFill.withOpacity(0.6),
                            width: 1.5
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "$chapter",
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: isRead ? FontWeight.bold : FontWeight.normal,
                            color: isRead ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  );
                },
            )
        )
      ],
    );
  }
}
