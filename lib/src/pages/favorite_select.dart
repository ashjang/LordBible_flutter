import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lord_bible/src/data/bible_data.dart';
import 'package:lord_bible/src/data/getFavoriteWord.dart';

class FavoriteSelect extends StatefulWidget {
  final Map<String, String> word;

  const FavoriteSelect({
    super.key,
    required this.word
  });

  @override
  State<FavoriteSelect> createState() => _FavoriteSelectState();
}

class _FavoriteSelectState extends State<FavoriteSelect> {
  final GetFavoriteWord _getFavoriteWord = GetFavoriteWord();
  // final GetFavoriteWord2 _getFavoriteWord = GetFavoriteWord2();
  bool isLoading = false;
  List<Map<String, String>> favoriteData = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteData();
  }

  Future<void> _loadFavoriteData() async {
    setState(() {
      isLoading = true;
    });

    final data = await _getFavoriteWord.fetchFavoriteData(widget.word['book']!, widget.word['chapter']!, widget.word['verse']!);
    setState(() {
      favoriteData = data!;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CupertinoNavigationBar(
        heroTag: 'favorite_select_tag',
        transitionBetweenRoutes: false,
        middle: Text("${tr(widget.word['book']!)} ${widget.word['chapter']}:${widget.word['verse']}",
            style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        leading: CupertinoButton(padding: EdgeInsets.all(0.0),
            child: Text(tr("Cancel"), style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white : Colors.black)),
            onPressed: () => {
              Navigator.pop(context)
            }),
        backgroundColor: Colors.transparent,
      ),
      body: isLoading ? Center(child: CupertinoActivityIndicator(radius: 20.0, color: Colors.grey),)
          : Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(favoriteData.length, (index) {
              final colors = [isDarkMode ? Colors.white : Colors.black, Colors.red, Colors.blue, Colors.green];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "${favoriteData[index]['version']}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: colors[index % colors.length]),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                              text:
                              "${tr(widget.word['book']!)} ${widget.word['chapter']}:${widget.word['verse']} (${favoriteData[index]['version']})\n${favoriteData[index]['word']}"));
                          Fluttertoast.showToast(msg: tr("Copied"), backgroundColor: Colors.grey);
                        },
                        child: Icon(
                          Icons.copy,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${favoriteData[index]['word']}",
                    style: TextStyle(color: colors[index % colors.length]),
                  ),
                  SizedBox(height: 40),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
