import 'package:get/get.dart';
import 'package:promptly/controllers/HomeController.dart';
import 'package:promptly/in_app_purchase/purchase_controller.dart';
import '../providers/app_state.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // PurchaseController registered permanently so Get.find<PurchaseController>()
    // works from any screen throughout the app lifecycle.
    Get.put(PurchaseController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(AppController(), permanent: true);
  }
}