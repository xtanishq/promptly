import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:promptly/in_app_purchase/bloc/purchase_bloc.dart';
import 'package:promptly/in_app_purchase/iap_config.dart';
import 'package:promptly/in_app_purchase/screens/credit_screen.dart';
import 'package:promptly/in_app_purchase/screens/subscription_screen.dart' show UpsellScreen;
import 'package:promptly/injection.dart';
import '../../../services/google_ads_material/ads_variable.dart';
import '../../data/repositories/image_and_text_repository.dart';
import '../../../services/creations_storage.dart';
import '../../../pages/image_preview_page.dart';
import 'generation_loading_page.dart';

class ImageAndTextPage extends StatefulWidget {
  final String? initialPrompt;

  const ImageAndTextPage({Key? key, this.initialPrompt}) : super(key: key);

  @override
  State<ImageAndTextPage> createState() => _ImageAndTextPageState();
}

class _ImageAndTextPageState extends State<ImageAndTextPage> {
  final TextEditingController _promptController = TextEditingController();
  final ImageAndTextRepository _repository = ImageAndTextRepository();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null) {
      _promptController.text = widget.initialPrompt!;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _generateImage() {
    if (_isSubmitting) return;

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      Get.snackbar('Error', 'Please enter a prompt first.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_selectedImage == null) {
      Get.snackbar('Error', 'Please select an image first.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // ── Gate: must be subscribed ────────────────────────────────────────────
    if (!AdsVariable.isPurchase.value) {
      Get.to(
        () => const UpsellScreen(item: true),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 350),
      );
      return;
    }

    // ── Gate: must have enough credits ──────────────────────────────────────
    final purchaseBloc = getIt<PurchaseBloc>();
    if (!purchaseBloc.state.hasEnoughCredits(IapConfig.generateImageCost)) {
      Get.snackbar(
        'Not Enough Credits ⚡',
        'You need at least ${IapConfig.generateImageCost} credits to generate. Buy more!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E1E1E),
        colorText: Colors.orange,
        duration: const Duration(seconds: 3),
      );
      Get.to(
        () => const CreditScreen(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 350),
      );
      return;
    }

    // ── All gates passed → deduct credits & generate ─────────────────────
    purchaseBloc.add(const CreditSpent(IapConfig.generateImageCost));
    unawaited(_startGenerationFlow());
  }

  Future<void> _startGenerationFlow() async {
    final prompt = _promptController.text.trim();
    final imageFile = _selectedImage;
    if (imageFile == null) return;

    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });

    final generationFuture = _repository.generateImage(imageFile, prompt);
    Either<String, String>? completedResult;

    unawaited(
      generationFuture.then((result) {
        completedResult = result;
      }),
    );

    setState(() {
      _isLoading = false;
      _isSubmitting = false;
    });

    final immediateResult = completedResult;
    if (immediateResult != null) {
      await _handleGenerationResult(immediateResult);
      return;
    }

    Get.to(
      () => GenerationLoadingPage(generationFuture: generationFuture),
    );
  }

  Future<void> _handleGenerationResult(Either<String, String> result) async {
    await result.fold(
      (error) async {
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
        Get.snackbar(
          'Success',
          'Image generated successfully! ✨',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E1E1E),
          colorText: const Color(0xFFCCFF00),
        );
        Get.off(() => ImagePreviewPage(imageUrl: imageUrl));
      },
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Generate Custom Image",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE PICKER
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24, width: 1),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_photo_alternate, size: 64, color: Colors.white70),
                            SizedBox(height: 16),
                            Text(
                              "Tap to select your base image",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 32),
              
              // TEXT FIELD
              const Text(
                "Customize the prompt",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: TextField(
                  controller: _promptController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "E.g., Turn this into a futuristic sci-fi scene...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // GENERATE BUTTON
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCCFF00)),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _generateImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCCFF00),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text(
                          "GENERATE NOW",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
