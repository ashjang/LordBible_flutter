import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class GetChapterWord {
  final FirebaseDatabase db = FirebaseDatabase.instance;

  Future<List<Map<String, String>>> fetchData(String version, String book, String chapter) async {
    try {
      DatabaseReference ref = db.ref().child(version).child(book).child(chapter);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = List<Map<dynamic, dynamic>>.from(snapshot.value as List);
        return data.map((item) {
          return {
            "verse": item["verse"].toString(),
            "word": item["word"].toString()
          };
        }).toList();
      } else {
        return [];
      }
    } catch(e) {
      print("ERROR: $e");
      return [];
    }
  }

  Future<int> getNumOfVerse(String book, String chapter) async {
    try {
      DatabaseReference ref = db.ref().child('NIV').child(book).child(chapter);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = List<Map<dynamic, dynamic>>.from(snapshot.value as List);
        return data.length;
      } else {
        return -1;
      }
    } catch(e) {
      print("ERROR: $e");
      return -1;
    }
  }
}
