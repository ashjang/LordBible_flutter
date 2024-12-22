import 'dart:convert';
import 'package:flutter/services.dart';

class JsonSearch {
  Future<List<Map<String, String>>> searchInJsonFile(String version, String query) async {
    // assets 폴더의 JSON 파일 읽기
    String filePath = "assets/$version.json";
    final fileContents = await rootBundle.loadString(filePath);
    final Map<String, dynamic> jsonData = jsonDecode(fileContents);

    List<Map<String, String>> results = [];

    void search(Map<String, dynamic> data, String bookName) {
      data.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            if (item is Map<String, dynamic>) {
              if (item['word'] != null && item['word'].contains(query)) {
                results.add({
                  'book': bookName,
                  'chapter': item['chapter'],
                  'verse': item['verse'],
                  'word': item['word']
                });
              }
            }
          }
        } else if (value is Map<String, dynamic>) {
          search(value, bookName);
        }
      });
    }

    jsonData.forEach((bookName, bookData) {
      if (bookData is Map<String, dynamic>) {
        search(bookData, bookName);
      }
    });

    return results;
  }
}
