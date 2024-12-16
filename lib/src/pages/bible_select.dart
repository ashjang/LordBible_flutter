import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BibleSelect extends StatefulWidget {
  const BibleSelect({super.key});

  @override
  State<BibleSelect> createState() => _BibleSelectState();
}

class _BibleSelectState extends State<BibleSelect> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
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
      child: CustomScrollView(

      ),
    );
  }
}
