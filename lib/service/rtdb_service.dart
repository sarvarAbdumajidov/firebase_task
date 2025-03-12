import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_task/service/log_service.dart';
import '../model/post_model.dart';

class RTDBService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref().child('posts');

  /// 🔹 Yangi post qo‘shish
  static Future<void> addPost(Post post) async {
    await _database.push().set(post.toJson());
  }

  /// 🔹 Barcha postlarni olish (Firebase `key`-larisiz)
  static Future<List<Post>> getPosts() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("posts");

    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries.map((e) => Post.fromJson(Map<String, dynamic>.from(e.value))).toList();
      } else {
        return [];
      }
    } catch (e) {
      LogService.e("Error getting posts: $e");
      return [];
    }
  }


  /// 🔹 Real-time postlarni olish (Stream)
  static Stream<List<Post>> getPostStream() {
    return _database.onValue.map((event) {
      List<Post> posts = [];
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          posts.add(Post.fromJson(value));
        });
      }
      return posts;
    });
  }
}
