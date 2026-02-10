import 'package:get/get.dart';
import 'package:promptly/controllers/HomeController.dart';
import '../providers/app_state.dart';
import 'network_controller.dart';
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Get.put(NetworkController(), permanent: true);
    Get.put(HomeController(),permanent: true);
    Get.put(AppController(), permanent: true); // Add your AppState here
  }
}