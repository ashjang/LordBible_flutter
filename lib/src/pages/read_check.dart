import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lord_bible/src/controller/bible_select_book.dart';
import 'package:lord_bible/src/data/bible_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadCheck extends StatefulWidget {
  const ReadCheck({super.key});

  @override
  State<ReadCheck> createState() => _ReadCheckState();
}

class _ReadCheckState extends State<ReadCheck> {
  int count = 0;
  int _selectedSegment = 0;
  String? selectedBook;
  String? selectedChapter;
  String? address = tr("Please choose book first");
  List<Map<String, String>> readList = [];

  @override
  void initState() {
    super.initState();

  }

  Widget segmentView() {
    switch (_selectedSegment) {
      case 0:
        return BibleSelectBook(
          selectedBook: selectedBook,
          onBookedSelected: (book) {
            setState(() {
              selectedBook = book;
              address = "${tr(toLong[selectedBook]!)}";
              _selectedSegment = 1;
            });
          },
        );
      case 1:

      default:
        return Center(child: Text('Unknown'),);
    }
  }

  Future<void> _saveRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('readList', readList.map((e) => '${e['address']}:${e['chapter']}').toList());
  }

  void updateReadList(String chapter) {
    setState(() {
      final existingIdx = readList.indexWhere((e) =>
        e['address'] == selectedBook && e['chapter'] == chapter);
      if (existingIdx >= 0) {
        readList.removeAt(existingIdx);
      } else {
        readList.add({"address": selectedBook!, "chapter": chapter!});
      }
      _saveRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CupertinoNavigationBar(
        heroTag: 'read_check_tag',
        transitionBetweenRoutes: false,
        middle: Text(tr('Read Check Page'),
            style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        leading: CupertinoButton(padding: EdgeInsets.all(0.0),
            child: Text(tr("Cancel"), style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white : Colors.black)),
            onPressed: () => {
              Navigator.pop(context)
            }),
        backgroundColor: Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.transparent))
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('bible_read_count'.tr(args: [count.toString()]), textAlign: TextAlign.right,),
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CupertinoSlidingSegmentedControl(
                backgroundColor: isDarkMode ? Colors.white30 : CupertinoColors.systemFill.withOpacity(0.6),
                thumbColor: Colors.white54,

                children: {
                  0: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(tr('Book'), style:
                    TextStyle(fontWeight: FontWeight.bold, color: _selectedSegment == 0 ? (Colors.black38) : (Colors.white)),),
                  ),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(tr('Chapter'), style:
                    TextStyle(fontWeight: FontWeight.bold, color: _selectedSegment == 1 ? Colors.black38 : Colors.white),),
                  ),
                },
                groupValue: _selectedSegment,
                onValueChanged: (int? value) {
                  setState(() {
                    _selectedSegment = value!;
                  });
                }
            ),
          ),
          Text("${address}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black54)),
          SizedBox(height: 10,),
          Expanded(child: segmentView())
        ],
      ),
    );
  }
}
