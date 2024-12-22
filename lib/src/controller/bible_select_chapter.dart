import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BibleSelectChapter extends StatelessWidget {
  final String? selectedBook;         // 현재 선택된 책
  final int chapterCount;             // 선택된 책의 장 수
  final String? selectedChapter;         // 선택된 장
  final ValueChanged<String> onChapterSelected; // 선택된 장을 전달하는 콜백

  const BibleSelectChapter({
    super.key,
    required this.selectedBook,
    required this.chapterCount,
    required this.selectedChapter,
    required this.onChapterSelected
  });

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    int crossAxisCount = textScaleFactor > 1.3 ? 5 : 6;
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    if (selectedBook == null) {
      return Center(child: Text(tr("Please choose book first")));
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
            itemCount: chapterCount,
            itemBuilder: (context, index) {
              String chapter = (index + 1).toString();
              return GestureDetector(
                onTap: () => onChapterSelected(chapter), // 선택된 장을 부모로 전달
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedChapter == chapter
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
                        fontWeight: selectedChapter == chapter ? FontWeight.bold : FontWeight.normal,
                        color: selectedChapter == chapter ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
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
