import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GetRandomWord extends StatefulWidget {
  const GetRandomWord({super.key});

  @override
  State<GetRandomWord> createState() => GetRandomWordState();
}

class GetRandomWordState extends State<GetRandomWord> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    print("[Firebase] Initializing...");
    _fetchData();
  }

  int month = DateTime.now().month - 1;
  int day = DateTime.now().day;

  void _fetchData() {
    print("[Firebase] Fetching data from Firebase...");
    db.child('randomWord').child('KJV흠정역').child('$month').child('$day').onValue.listen((event) {
      final realData = event.snapshot.value as Map?;
      if (realData != null) {
        setState(() {
          data = Map<String, dynamic>.from(realData);
          loading = false;
          print("[Firebase] Data import success from Firebase");
        });
      } else {
        print("[Firebase] No Data");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Padding(padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: CupertinoActivityIndicator(radius: 20.0, color: Colors.grey),)) : Column(
          children: [
            Row(
              children: [
                Align(alignment: Alignment.centerLeft,
                  child: Text("${tr(data!['address'])} ${data!['chapter']}:${data!['verse']} (KJV흠정역)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                        text:
                        "${tr(data!['address'])} ${data!['chapter']}:${data!['verse']}\n${data!['word']}"));
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
          Align(alignment: Alignment.centerLeft,
            child: Text("${data!['word']}", overflow: TextOverflow.ellipsis, maxLines: 10, style: TextStyle(fontSize: 14.0),)
          ,)

        ],
    );
  }
}