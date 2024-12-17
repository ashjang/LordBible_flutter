import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lord_bible/src/controller/bible_select_book.dart';
import 'package:lord_bible/src/controller/bible_select_chapter.dart';
import 'package:lord_bible/src/data/bible_data.dart';

class BibleSelect extends StatefulWidget {
  const BibleSelect({super.key});

  @override
  State<BibleSelect> createState() => _BibleSelectState();
}

class _BibleSelectState extends State<BibleSelect> {
  int _selectedSegment = 0;
  String? address = "Please choose book first";
  String? selectedBook;
  String? selectedChapter;

  void _showAlert(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Warning"),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  Widget segmentView() {
    switch (_selectedSegment) {
      case 0:
        return BibleSelectBook(
          selectedBook: selectedBook,
          onBookedSelected: (book) {
            setState(() {
              selectedBook = book;
              selectedChapter = null;
              address = "book: $book";
              _selectedSegment = 1;
            });
          },
        );
      case 1:
        return BibleSelectChapter(
          selectedBook: selectedBook,
          chapterCount: selectedBook != null ? bibleData[selectedBook]! : 0,
          selectedChapter: selectedChapter,
          onChapterSelected: (chapter) {
            setState(() {
              selectedChapter = chapter;
              address = "book: $selectedBook\nchapter: $chapter";
            });
          },
        );
      default:
        return Center(child: Text('Unknown'),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
          heroTag: 'bible_select_tag',
          transitionBetweenRoutes: false,
          middle: Text("Select", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: CupertinoButton(padding: EdgeInsets.all(0.0),
              child: Text("Cancel", style: TextStyle(fontSize: 18.0)),
              onPressed: () => {
                Navigator.pop(context)
              }),
          trailing: CupertinoButton(padding: EdgeInsets.all(0.0),
              child: Text("Done", style: TextStyle(fontSize: 18.0),),
              onPressed: () => {
                if (selectedBook == null || selectedChapter == null) {
                  _showAlert(context, "Please select both a book and a chapter")
                } else {
                  Navigator.pop(context, {
                    'selectedBook': selectedBook,
                    'selectedChapter': selectedChapter,
                    })
                }
              }),
          backgroundColor: Colors.transparent,
          border: Border(bottom: BorderSide(color: Colors.transparent))
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CupertinoSlidingSegmentedControl(
                backgroundColor: CupertinoColors.systemGrey2,
                thumbColor: Colors.white54,

                children: {
                  0: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Book', style:
                    TextStyle(fontWeight: FontWeight.bold, color: _selectedSegment == 0 ? Colors.black38 : Colors.white),),
                  ),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Chapter', style:
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

          Text("${address}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),),
          SizedBox(height: 10,),
          Expanded(child: segmentView())
        ],
      ),
    );
  }
}

