import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressor {
  /// Compresses the given [XFile] and returns a new [XFile] pointing to the compressed image.
  /// If compression fails, it returns the original file.
  static Future<XFile> compressImage(XFile file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.absolute.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70,
        minWidth: 1080,
        minHeight: 1080,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        return result;
      }
    } catch (e) {
      // If any error occurs during compression, fallback to original
    }
    return file;
  }
}
