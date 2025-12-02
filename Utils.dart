import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import '../core/constants.dart';

class MediaUtils {
  static Future<File> compressImage(File file) async {
    final targetPath = '${file.parent.path}/compressed_${file.uri.pathSegments.last}';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 800,
      minHeight: 800,
    );
    if (result == null) return file;
    if (await result.length() > AppConstants.maxImageSizeBytes) {
      final result2 = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.parent.path}/compressed2_${file.uri.pathSegments.last}',
        quality: 60,
      );
      return result2 ?? result;
    }
    return result;
  }

  static Future<File?> compressVideo(File file) async {
    await VideoCompress.setLogLevel(0);
    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    if (info == null || info.file == null) return null;
    final compressed = info.file!;
    if (await compressed.length() > AppConstants.maxVideoSizeBytes) {
      final info2 = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      return info2?.file;
    }
    return compressed;
  }
}
