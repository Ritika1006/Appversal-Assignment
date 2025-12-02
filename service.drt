import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = Uuid();

  /// returns upload task so caller can listen snapshotEvents for progress
  UploadTask uploadFile(File file, String path) {
    final ref = _storage.ref().child(path);
    return ref.putFile(file);
  }

  /// high-level uploader: compresses must be done before calling
  Future<String> uploadFileAndGetUrl(File file, String folder) async {
    final fileName = '${_uuid.v4()}_${file.path.split('/').last}';
    final task = uploadFile(file, '$folder/$fileName');
    final snapshot = await task;
    return snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFileByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }
}
