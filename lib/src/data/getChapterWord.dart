import 'dart:convert';

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

class GetChapterWord2 {
  Future<List<Map<String, String>>> fetchData(String version, String book, String chapter) async {
    try {
      String filePath = "assets/$version.json";
      final fileContents = await rootBundle.loadString(filePath);
      final data = json.decode(fileContents) as Map<String, dynamic>; // JSON 파싱

      if (data.containsKey(book) &&
          data[book].containsKey(chapter)) {
        // 특정 책과 장 데이터를 가져옴
        final verses = data[book][chapter] as List<dynamic>;
        return verses.map((item) {
          return {
            "verse": item["verse"].toString(),
            "word": item["word"].toString()
          };
        }).toList();
      } else {
        return []; // 데이터가 없을 경우 빈 리스트 반환
      }
    } catch (e) {
      print("ERROR: $e");
      return []; // 에러 발생 시 빈 리스트 반환
    }
  }

  Future<int> getNumOfVerse(String book, String chapter) async {
    try {
      String filePath = "assets/KJV.json";
      final fileContents = await rootBundle.loadString(filePath);
      final data = json.decode(fileContents) as Map<String, dynamic>; // JSON 파싱

      if (data.containsKey(book) && data[book].containsKey(chapter)) {
        final verses = data[book][chapter] as List; // 장 데이터를 List로 가져옴
        return verses.length; // 구절 개수 반환
      } else {
        return -1; // 책 또는 장이 없을 경우 -1 반환
      }
    } catch (e) {
      print("ERROR: $e");
      return -1; // 에러 발생 시 -1 반환
    }
  }
}
