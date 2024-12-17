import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
            Align(alignment: Alignment.topLeft,
            child: Text("${data!['address']} ${data!['chapter']}:${data!['verse']} (KJV흠정역)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),),
            Text("${data!['word']}", overflow: TextOverflow.ellipsis, maxLines: 6, style: TextStyle(fontSize: 12.0),)
          ],
    );
  }
}