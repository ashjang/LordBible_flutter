import 'package:firebase_database/firebase_database.dart';

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
}