import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lord_bible/src/controller/bible_select_book.dart';

class BibleSelect extends StatefulWidget {
  const BibleSelect({super.key});

  @override
  State<BibleSelect> createState() => _BibleSelectState();
}

class _BibleSelectState extends State<BibleSelect> {
  int _selectedSegment = 0;
  String? address = "선택된 주소";
  String? selectedBook;
  int? chapter;
  int? verse;

  Widget segmentView() {
    switch (_selectedSegment) {
      case 0:
        return BibleSelectBook(
          selectedBook: selectedBook,
          onBookedSelected: (book) {
            setState(() {
              selectedBook = book;
              address = "$book";
              _selectedSegment = 1;
            });
          },
        );
      case 1:
        return Center(child: Text('Chapter'),);
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
          middle: Text("Select Bible Verses", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: CupertinoButton(padding: EdgeInsets.all(0.0),
              child: Text("Cancel"),
              onPressed: () => {
                Navigator.pop(context)
              }),
          trailing: CupertinoButton(padding: EdgeInsets.all(0.0),
              child: Text("Done"),
              onPressed: () => {
                // 선택한 성경구절 저장
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

          Text("${address}"),
          SizedBox(height: 10,),
          Expanded(child: segmentView())
        ],
      ),
    );
  }
}

