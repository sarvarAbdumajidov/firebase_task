import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_task/service/log_service.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 🔹 Rasm va video fayllarni Firebase Storage-ga yuklash
  static Future<Map<String, String>> uploadMedia(File? image, File? video) async {
    Map<String, String> urls = {};

    try {
      if (image != null) {
        urls['image'] = await _uploadFile(image, 'images') ?? '';
      }
      if (video != null) {
        urls['video'] = await _uploadFile(video, 'videos') ?? '';
      }
    } catch (e) {
      LogService.e("Media yuklashda xatolik: $e");
    }

    return urls;
  }

  /// 🔹 Faylni Firebase Storage-ga yuklab, URL qaytarish
  static Future<String?> _uploadFile(File file, String folder) async {
    try {
      String fileName =
          "$folder/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}";
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      LogService.i("$folder yuklandi: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      LogService.e("$folder yuklashda xatolik: $e");
      return null;
    }
  }
}
