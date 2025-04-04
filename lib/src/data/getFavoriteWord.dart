import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class GetFavoriteWord {
  final FirebaseDatabase db = FirebaseDatabase.instance;
  List<String> versions = ["KJV흠정역", "KJV", "개역개정", "NIV"];

  Future<List<Map<String, String>>> fetchFavoriteData(String book, String chapter, String verse) async {
    List<Map<String, String>> resultData = [];

    for (String version in versions) {
      try {
        DatabaseReference ref = db.ref().child(version).child(book).child(chapter);
        final snapshot = await ref.get();
        if (snapshot.exists) {
          List<dynamic> verses = snapshot.value as List<dynamic>;
          resultData.add({
            "version": version,
            "book": book,
            "chapter": chapter,
            "verse": verses[int.parse(verse) - 1]["verse"],
            "word": verses[int.parse(verse) - 1]["word"],
          });
        } else {
          return [];
        }
      } catch(e) {
        print("ERROR: $e");
        return [];
      }
    }
      return resultData;
  }
}

class GetFavoriteWord2 {
  List<String> versions = ["KJV흠정역", "KJV", "개역개정", "NIV"];

  Future<List<Map<String, String>>> fetchFavoriteData(String book, String chapter, String verse) async {
    List<Map<String, String>> resultData = [];

    for (String version in versions) {
      try {
        String filePath = "assets/$version.json";
        final fileContents = await rootBundle.loadString(filePath);
        final data = json.decode(fileContents) as Map<String, dynamic>; // JSON 파싱

        if (data.containsKey(book) &&
          data[book].containsKey(chapter)) {
          final verses = data[book][chapter] as List<dynamic>;
          resultData.add({
            "version": version,
            "book": book,
            "chapter": chapter,
            "verse": verses[int.parse(verse) - 1]["verse"],
            "word": verses[int.parse(verse) - 1]["word"],
          });
        }

      } catch(e) {
        print("ERROR: $e");
        return [];
      }
    }
    return resultData;
  }
}