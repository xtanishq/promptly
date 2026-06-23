import 'package:get/get.dart';
import 'package:promptly/controllers/HomeController.dart';
import '../providers/app_state.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Monetization now lives in PurchaseBloc (get_it singleton, see injection.dart).
    Get.put(HomeController(), permanent: true);
    Get.put(AppController(), permanent: true);
  }
}