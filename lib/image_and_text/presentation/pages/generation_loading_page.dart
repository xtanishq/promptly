import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fpdart/fpdart.dart' show Either;

import '../../../services/creations_storage.dart';
import '../../../pages/image_preview_page.dart';

class GenerationLoadingPage extends StatefulWidget {
  final Future<Either<String, String>> generationFuture;

  const GenerationLoadingPage({
    super.key,
    required this.generationFuture,
  });

  @override
  State<GenerationLoadingPage> createState() => _GenerationLoadingPageState();
}

class _GenerationLoadingPageState extends State<GenerationLoadingPage> {
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _awaitGeneration();
  }

  Future<void> _awaitGeneration() async {
    final result = await widget.generationFuture;
    if (!mounted || _isCompleted) return;

    _isCompleted = true;
    await result.fold(
      (error) async {
        Get.back();
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
      (imageUrl) async {
        await CreationsStorage.saveCreation(imageUrl);
        Get.off(() => ImagePreviewPage(imageUrl: imageUrl));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFCCFF00),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Generating your image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your edit is still processing. We will open the result automatically as soon as it is ready.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
