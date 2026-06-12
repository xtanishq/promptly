import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import '../../../utils/auth_repository.dart';

class ImageAndTextRepository {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    ),
  );

  Future<Either<String, String>> generateImage(File imageFile, String prompt) async {
    try {
      debugPrint("🚀 Starting image generation...");
      debugPrint("📁 Image path: ${imageFile.path}");
      debugPrint("📝 Prompt: $prompt");

      final formData = FormData.fromMap({
        'prompt': prompt,
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final token = AuthRepository().accessToken;
      if (token == null) {
        debugPrint("❌ No access token found in AuthRepository.");
        return Left("Authentication failed. Please restart the app.");
      }

      debugPrint("📡 Sending request to Cloudflare Worker with token...");
      final response = await _dio.post(
        'https://my-worker.scratched.workers.dev/api/generate',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint("✅ Response Status: ${response.statusCode}");
      debugPrint("📦 Response Data: ${response.data}");

      final Map<String, dynamic> data = response.data is String ? {'error': 'Invalid JSON response'} : response.data;

      if (data['status'] == 'completed' && data['finalImageUrl'] != null) {
        debugPrint("🎉 Success! Image URL: ${data['finalImageUrl']}");
        return Right(data['finalImageUrl']);
      } else {
        final errorMsg = data['error'] ?? 'Unknown error';
        debugPrint("❌ API returned error: $errorMsg");
        return Left("Failed to generate image: $errorMsg");
      }
    } on DioException catch (e) {
      debugPrint("🔴 DioException caught!");
      debugPrint("Message: ${e.message}");
      debugPrint("Response: ${e.response?.data}");
      
      String? errorMessage;
      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          errorMessage = (e.response!.data as Map<String, dynamic>)['error']?.toString();
        } else if (e.response!.data is String) {
          // If Cloudflare returns HTML error like 502 Bad Gateway
          errorMessage = "Server error (${e.response?.statusCode})";
        }
      }

      return Left(errorMessage ?? e.message ?? "Network error occurred");
    } catch (e) {
      debugPrint("💥 Unexpected Exception: $e");
      return Left(e.toString());
    }
  }
}
