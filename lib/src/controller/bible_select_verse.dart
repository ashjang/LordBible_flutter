import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BibleSelectVerse extends StatelessWidget {
  final String? selectedBook;         // 현재 선택된 책
  final int verseCount;             // 선택된 책의 잘 수
  final String? selectedChapter;         // 선택된 장
  final String? selectedVerse;         // 선택된 절
  final ValueChanged<String> onVerseSelected; // 선택된 장을 전달하는 콜백

  const BibleSelectVerse({
    super.key,
    required this.selectedBook,
    required this.verseCount,
    required this.selectedChapter,
    required this.selectedVerse,
    required this.onVerseSelected
  });

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    int crossAxisCount = textScaleFactor > 1.3 ? 5 : 6;
    double fontSize = MediaQuery.of(context).size.width * 0.04;

    if (selectedBook == null || selectedChapter == null) {
      return const Center(child: Text("Please choose book or verse first"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20)
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // 한 줄에 5개의 버튼
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: verseCount,
            itemBuilder: (context, index) {
              String verse = (index + 1).toString();
              return GestureDetector(
                onTap: () => onVerseSelected(verse), // 선택된 장을 부모로 전달
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedVerse == verse
                        ? CupertinoColors.systemFill.withOpacity(0.7)
                        : CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "$verse",
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: selectedVerse == verse ? FontWeight.bold : FontWeight.normal,
                        color: selectedVerse == verse ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
