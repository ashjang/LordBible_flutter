import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lord_bible/src/controller/bible_select_book.dart';
import 'package:lord_bible/src/controller/bible_select_chapter.dart';
import 'package:lord_bible/src/data/bible_data.dart';
import 'package:lord_bible/src/data/getChapterWord.dart';

import '../controller/bible_select_verse.dart';

class BibleSelect extends StatefulWidget {
  const BibleSelect({super.key});

  @override
  State<BibleSelect> createState() => _BibleSelectState();
}

class _BibleSelectState extends State<BibleSelect> {
  int _selectedSegment = 0;
  String? address = tr("Please choose book first");
  String? selectedBook;
  String? selectedChapter;
  String? selectedVerse;

  Widget segmentView() {
    switch (_selectedSegment) {
      case 0:
        return BibleSelectBook(
          selectedBook: selectedBook,
          onBookedSelected: (book) {
            setState(() {
              selectedBook = book;
              selectedChapter = null;
              selectedVerse = null;
              address = "${tr(toLong[selectedBook]!)}";
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
              address = "${tr(toLong[selectedBook]!)} $chapter";
              _selectedSegment = 2;
            });
          },
        );
      case 2:
        if (selectedBook != null && selectedChapter != null) {
          return FutureBuilder<int>(
            future: GetChapterWord().getNumOfVerse(toLong['${selectedBook}']!, selectedChapter!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator(radius: 20.0, color: Colors.grey));
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data! < 0) {
                return const Center(child: Text("Invalid data or no verses available"));
              } else {
                return BibleSelectVerse(
                  selectedBook: selectedBook,
                  verseCount: snapshot.data!,
                  selectedChapter: selectedChapter,
                  selectedVerse: selectedVerse,
                  onVerseSelected: (verse) {
                    setState(() {
                      selectedVerse = verse;
                      address = "${tr(toLong[selectedBook]!)} $selectedChapter:$verse";
                      Navigator.pop(context, {
                        'selectedBook': selectedBook,
                        'selectedChapter': selectedChapter,
                        'selectedVerse': selectedVerse,
                      });
                    });
                  },
                );
              }
            },
          );
        } else {
          return Center(child: Text(tr("Please choose book and verse")));
        }
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
          middle: Text(tr("Select"), style: TextStyle(fontWeight: FontWeight.bold)),
          leading: CupertinoButton(padding: EdgeInsets.all(0.0),
              child: Text(tr("Cancel"), style: TextStyle(fontSize: 18.0)),
              onPressed: () => {
                Navigator.pop(context)
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
                    child: Text(tr('Book'), style:
                    TextStyle(fontWeight: FontWeight.bold, color: _selectedSegment == 0 ? Colors.black38 : Colors.white),),
                  ),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(tr('Chapter'), style:
                    TextStyle(fontWeight: FontWeight.bold, color: _selectedSegment == 1 ? Colors.black38 : Colors.white),),
                  ),
                  2: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(tr('Verse'), style:
                    TextStyle(fontWeight: FontWeight.bold, color: _selectedSegment == 2 ? Colors.black38 : Colors.white),),
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

