import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: CupertinoNavigationBar(
        heroTag: 'favorite_select_tag',
        transitionBetweenRoutes: false,
        middle: Text("${widget.word['book']} ${widget.word['chapter']}:${widget.word['verse']}", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading ? Expanded(child: Center(child: CupertinoActivityIndicator(radius: 20.0, color: Colors.grey),))
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1,
            vertical: MediaQuery.of(context).size.height * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${favoriteData[0]['version']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                  SizedBox(height: 8,),
                  Text("${favoriteData[0]['word']}"),
                  SizedBox(height: 40,)
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${favoriteData[1]['version']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.red),),
                  SizedBox(height: 8,),
                  Text("${favoriteData[1]['word']}", style: TextStyle(color: Colors.red),),
                  SizedBox(height: 40,)
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${favoriteData[2]['version']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue),),
                  SizedBox(height: 8,),
                  Text("${favoriteData[2]['word']}", style: TextStyle(color: Colors.blue),),
                  SizedBox(height: 40,)
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${favoriteData[3]['version']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.green),),
                  SizedBox(height: 8,),
                  Text("${favoriteData[3]['word']}", style: TextStyle(color: Colors.green),),
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}
