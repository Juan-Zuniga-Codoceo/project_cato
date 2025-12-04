import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileManagerService {
  /// Saves a file permanently to app's document directory
  /// Returns the permanent file path
  static Future<String> saveFilePermanently(
    File file,
    String subDirectory,
  ) async {
    try {
      // Get application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();

      // Create custom subdirectory
      final String dirPath = path.join(
        appDocDir.path,
        'app_docs',
        subDirectory,
      );
      final Directory dir = Directory(dirPath);

      // Create directory if it doesn't exist
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Generate unique filename: timestamp + original extension
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(file.path);
      final String fileName = '$timestamp$extension';

      // Create permanent file path
      final String permanentPath = path.join(dirPath, fileName);

      // Copy file to permanent location
      final File permanentFile = await file.copy(permanentPath);

      print('📁 Archivo guardado permanentemente: $permanentPath');

      return permanentFile.path;
    } catch (e) {
      print('❌ Error guardando archivo permanentemente: $e');
      rethrow;
    }
  }

  /// Deletes a file at the given path
  static Future<void> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Archivo eliminado: $filePath');
      }
    } catch (e) {
      print('❌ Error eliminando archivo: $e');
    }
  }

  /// Checks if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Gets file extension
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Checks if file is an image
  static bool isImageFile(String filePath) {
    final ext = getFileExtension(filePath);
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(ext);
  }

  /// Checks if file is a PDF
  static bool isPdfFile(String filePath) {
    return getFileExtension(filePath) == '.pdf';
  }
}
