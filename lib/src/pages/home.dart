import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lord_bible/src/data/getRandomWord.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _todayWord() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.book_fill, color: Colors.grey[600]),
            SizedBox(width: 5),
            Text("Today's word", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ],
        ),
        SizedBox(height: 6),
        GetRandomWord(),
        SizedBox(height: 30),
      ]
    );
  }

  Widget _favoriteWord() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.star_fill, color: Colors.yellow,),
              SizedBox(width: 5),
              Text("Favorite words", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))
            ],
          ),
          SizedBox(width: 6),
            // 즐겨찾는 말씀 로직 구현하기
        ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
            child: Column(
              children: [
                SizedBox(height: 20),
                _todayWord(),
                SizedBox(height: 20),
                _favoriteWord()
              ],
            )
        )
    );
  }
}
