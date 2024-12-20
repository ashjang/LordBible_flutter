import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lord_bible/src/data/bible_data.dart';

class BibleSelectBook extends StatelessWidget {
  final String? selectedBook;
  final ValueChanged<String> onBookedSelected;

  const BibleSelectBook({
    super.key,
    required this.selectedBook,
    required this.onBookedSelected,
  });

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    int crossAxisCount = textScaleFactor > 1.3 ? 4 : 5;
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(tr("Old Testament"),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black54),
            ),
          ),
          buildGridView(context, oldTestament, crossAxisCount),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(tr("New Testament"),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black54),
            ),
          ),
          buildGridView(context, newTestament, crossAxisCount),
        ],
      ),
    );
  }

  Widget buildGridView(BuildContext context, List<String> books, int crossAxisCount) {
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        String book = books[index];
        return GestureDetector(
          onTap: () => onBookedSelected(book),
          child: Container(
            decoration: BoxDecoration(
              color: selectedBook == book
                  ? (isDarkMode ? Colors.white30 : CupertinoColors.systemFill.withOpacity(0.6))
                  : (isDarkMode ? Colors.white70 : CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                tr("ShortNames.${book}"),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selectedBook == book ? FontWeight.bold : FontWeight.normal,
                  color: selectedBook == book ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

