import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/num_extensions.dart';
import '../data/prompt_data.dart';
import '../data/prompt_data.dart' as _configService;
import '../data/prompt_model.dart';
import '../services/firebase_configuration/RemoteConfigService.dart';
import '../utils/AppRoutes.dart';
import 'ImagePrecacheService.dart';

class HomeController extends GetxController {
  // Reactive variables
  var prompts = <Prompt>[].obs;
  var filteredPrompts = <Prompt>[].obs;
  var categories = <String>['All'].obs;
  var selectedCategory = 'All'.obs;
  var dailyDiscovery = Rxn<Prompt>();
  var isLoading = true.obs;
  var premiumPrompts = <Prompt>[].obs; // Reactive List for PageView
  @override
  void onInit() {
    super.onInit();
    loadRemoteData();
  }

  void loadRemoteData() async {
    try {
      final remoteService = Get.find<RemoteConfigService>();

      // 1. Data fetch karne ki koshish karein
      final data = await remoteService.getPrompts();

      if (data.isNotEmpty) {
        debugPrint("🔥 Firebase Prompts Loaded: ${data.length} items");
        _updateLocalState(data);
      } else {
        // 2. FALLBACK: Agar internet nahi hai ya data empty hai
        debugPrint("📡 No Internet or Empty Firebase: Loading Local Fallback");
        final localData = getPrompts(); // Aapka purana local data function
        _updateLocalState(localData);
      }

      // 3. Pre-caching logic (Sirf tabhi chalega jab context ho)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null && prompts.isNotEmpty) {
          _precacheImages(prompts.toList());
        }
      });
    } catch (e) {
      debugPrint("❌ Remote Data Error: $e");
      // Catch mein bhi fallback load karein taaki app crash na ho
      _updateLocalState(getPrompts());
    } finally {
      isLoading.value = false;
    }
  }

  void _updateLocalState(List<Prompt> data) {
    prompts.assignAll(data);
    filteredPrompts.assignAll(data);

    if (data.isNotEmpty) {

      // dailyDiscovery.value = premiumPrompt;
      final premiumItems = data
          .where((p) => p.category.toLowerCase() == 'premium')
          .toList();

      // 2. Assign to the premiumPrompts list
      premiumPrompts.assignAll(
        premiumItems.isNotEmpty ? premiumItems : [data.first],
      );

      // Categories list banate waqt hum 'premium' ko list se hide kar sakte hain
      // agar aap use selector mein nahi dikhana chahte.
      final cats = data
          .map((e) => e.category)
          .where(
            (cat) => cat.toLowerCase() != 'premium',
          ) // 'Premium' ko selector se hatane ke liye
          .toSet()
          .toList();

      categories.assignAll(['All', ...cats]);
    }
  }

  Future<void> _precacheImages(List<Prompt> items) async {
    // Only precache the first 5-10 images to avoid blocking the network
    final initialItems = items.take(10).toList();

    List<Future> precacheFutures = [];

    for (var prompt in initialItems) {
      if (prompt.imageUrl.isNotEmpty && Get.context != null) {
        final cacheFuture =
            precacheImage(
                  CachedNetworkImageProvider(
                    prompt.imageUrl,
                    // ⚡ CRITICAL: Force resize to stop the 10-second hang
                    maxHeight: 600,
                    maxWidth: 400,
                  ),
                  Get.context!,
                )
                .then((_) => debugPrint("✅ Precached & Resized: ${prompt.id}"))
                .catchError((e) => debugPrint("❌ Precache Error: $e"));

        precacheFutures.add(cacheFuture);
      }
    }

    // Wait for the first batch to finish before releasing the loading state
    await Future.wait(precacheFutures);
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    if (category == 'All') {
      filteredPrompts.value = prompts;
    } else {
      filteredPrompts.value = prompts
          .where((p) => p.category == category)
          .toList();
    }
  }

  void surpriseMe() {
    final random = Random();
    final prompt = prompts[random.nextInt(prompts.length)];
    // Get.toNamed(AppRoutes.detail, arguments: prompt);
    Get.toNamed(AppRoutes.detail, arguments: prompt);
    // return prompt;

    // Get.toNamed(page)
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (context) => DetailScreen(prompt: prompt)),
    // );
  }

  Future<void> refreshData() async {
    await Future.delayed(1.seconds);
    prompts.shuffle();
    filterByCategory(selectedCategory.value);
  }

  void onCategorySelected(String category) {
    selectedCategory.value = category; // Update the reactive string

    if (category == 'All') {
      filteredPrompts.value = prompts;
    } else {
      // Senior Tip: Always use .toList() to create a new reference
      // so the Obx detects the change properly.
      filteredPrompts.value = prompts
          .where((p) => p.category == category)
          .toList();
    }
  }
}
