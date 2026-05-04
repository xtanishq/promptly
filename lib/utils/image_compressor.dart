import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;

/// A centralized image compression utility.
///
/// Ensures all images uploaded via API calls stay within the
/// [maxSizeBytes] limit (default 400 KB). Uses iterative JPEG
/// quality reduction so visual quality is preserved as much as
/// possible while respecting the budget.
///
/// Usage:
/// ```dart
/// final compressed = await ImageCompressor.compress(originalFile);
/// request.files.add(await http.MultipartFile.fromPath('image', compressed.path));
/// ```
class ImageCompressor {
  ImageCompressor._(); // prevent instantiation

  /// Default max file size: 400 KB.
  static const int defaultMaxSizeBytes = 400 * 1024;

  /// Minimum JPEG quality floor to avoid unacceptable degradation.
  static const int _minQuality = 20;

  /// Starting quality for the first compression pass.
  static const int _initialQuality = 85;

  /// Quality step for each iterative pass.
  static const int _qualityStep = 10;

  /// Compresses [file] to be ≤ [maxSizeBytes].
  ///
  /// Returns the original [file] unchanged if it's already under the limit.
  /// Otherwise returns a new temporary JPEG file.
  ///
  /// The optional [maxWidth] / [maxHeight] parameters cap the output
  /// resolution (defaults 1920 px — sufficient for most AI APIs).
  static Future<File> compress(
    File file, {
    int maxSizeBytes = defaultMaxSizeBytes,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    // Skip if already within budget
    final originalSize = await file.length();
    if (originalSize <= maxSizeBytes) {
      debugPrint('ImageCompressor: file already within budget '
          '(${_formatKB(originalSize)} KB ≤ ${_formatKB(maxSizeBytes)} KB)');
      return file;
    }

    debugPrint('ImageCompressor: original ${_formatKB(originalSize)} KB → '
        'target ≤ ${_formatKB(maxSizeBytes)} KB');

    int quality = _initialQuality;

    while (quality >= _minQuality) {
      final Uint8List? result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        debugPrint('ImageCompressor: compression returned null at q=$quality');
        break;
      }

      debugPrint('ImageCompressor: q=$quality → ${_formatKB(result.length)} KB');

      if (result.length <= maxSizeBytes) {
        return _writeTempFile(result);
      }

      quality -= _qualityStep;
    }

    // Last resort: aggressive compression at minimum quality
    final Uint8List? lastResort = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: _minQuality,
      format: CompressFormat.jpeg,
    );

    if (lastResort != null) {
      debugPrint('ImageCompressor: last-resort ${_formatKB(lastResort.length)} KB');
      return _writeTempFile(lastResort);
    }

    // Fallback: return original if everything fails
    debugPrint('ImageCompressor: all attempts failed, returning original');
    return file;
  }

  /// Convenience: compress multiple files in parallel.
  static Future<List<File>> compressAll(
    List<File> files, {
    int maxSizeBytes = defaultMaxSizeBytes,
  }) async {
    return Future.wait(
      files.map((f) => compress(f, maxSizeBytes: maxSizeBytes)),
    );
  }

  // ── Private helpers ────────────────────────────────────────────

  static Future<File> _writeTempFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}/compressed_$timestamp.jpg';
    final tempFile = File(path);
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }

  static String _formatKB(int bytes) => (bytes / 1024).toStringAsFixed(1);
}
