import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lord_bible/src/pages/bible_select.dart';

class Bible extends StatefulWidget {
  const Bible({super.key});

  @override
  State<Bible> createState() => _BibleState();
}

class _BibleState extends State<Bible> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
            heroTag: 'bible_tag',
            transitionBetweenRoutes: false,
            middle: Text("Bible", style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: CupertinoButton(padding: EdgeInsets.all(0.0),
              child: Text("Select"),
              onPressed: () => {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => BibleSelect()))
              }),
            backgroundColor: Colors.transparent,
            border: Border(bottom: BorderSide(color: Colors.transparent))
        ),

      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
          child: Column(
            children: [
              // 버전 선택
              // 주소 선택(이전,이후)
              // 메뉴바, 순서
              // 리스트
            ],
          )
      )
    );
  }
}