import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lord_bible/src/data/bible_data.dart';
import 'package:lord_bible/src/data/getSearchWord.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late TextEditingController textController;
  final List<String> versions = ["KJV흠정역", "KJV", "개역개정", "NIV"];
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> results = [];
  String query = "";
  bool isLoading = false;
  String selectedVersion = "KJV흠정역";
  JsonSearch jsonSearch = JsonSearch();

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _onSearch(String value) async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, String>> foundVerses = await jsonSearch.searchInJsonFile(selectedVersion, query);

    setState(() {
      results = foundVerses;
      isLoading = false;
    });
  }

  void toggleSelect(String version) {
    setState(() {
      selectedVersion = version;
    });
  }

  List<TextSpan> _highlightQuery(String text, String query, Color highlightColor, Color defaultColor) {
    if (query.isEmpty) {
      return [TextSpan(text: text, style: TextStyle(color: defaultColor))];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int index;
    while ((index = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: TextStyle(color: defaultColor)));
      }
      spans.add(TextSpan(text: text.substring(index, index + query.length), style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold)));
      start = index + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: TextStyle(color: defaultColor)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CupertinoNavigationBar(
          heroTag: 'search_tag',
          transitionBetweenRoutes: false,
          middle: Text(tr('Search'), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
          backgroundColor: Colors.transparent,
          border: Border(bottom: BorderSide(color: Colors.transparent))
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Column(
              children: [
                _versionButton(),

                Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Row(
                      children: [
                        // 검색란
                        Expanded(
                          child: CupertinoSearchTextField(
                            controller: textController,
                            placeholder: '${tr('Type to search')}',
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                            onChanged: (value) {
                              setState(() {
                                query = value;
                              });
                            },
                            onSubmitted: (value) {
                              _onSearch(value);
                            },
                          ),
                        ),

                        CupertinoButton(
                          child: Text("확인", style: TextStyle(fontSize: 15.0, color: isDarkMode ? Colors.white : Colors.black)),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _onSearch(query);
                          },
                        )
                      ],
                    )
                ),

                listView(),
              ],
            ),

            if (isLoading)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false, // 터치 이벤트 전달 허용
                  child: Container(
                    color: Colors.black45.withOpacity(0.5), // 반투명 배경
                    child: Center(
                      child: CupertinoActivityIndicator(
                        radius: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      )
    );
  }

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
            final isSelected = selectedVersion == version;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => toggleSelect(version),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected
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
                      color: isSelected
                          ? Colors.white
                          : Colors.grey[500],
                      fontWeight: isSelected
                          ? FontWeight.normal
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

  Widget listView() {
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return Expanded(
        child: Scrollbar(
          thumbVisibility: true,
          interactive: true,
          thickness: 5.0,
          radius: Radius.circular(10.0),
          controller: _scrollController,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: results.length,
            separatorBuilder: (context, index) => Divider(
                color: Colors.grey[700],
                thickness: 0.8,
                height: 1.0,
              ),
            itemBuilder: (context, index) {
              final result = results[index];

              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 0,
                ),
                title: RichText(
                  textScaleFactor: textScaleFactor,
                  text: TextSpan(
                    children: _highlightQuery(
                      "(${tr("ShortNames.${toShort[result['book']]!}")} ${result['chapter']}:${result['verse']})  ${result['word']}",
                      query,
                      Colors.red,
                      isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                onTap: () { },
              );
            },
          ),
        )
    );
  }
}
