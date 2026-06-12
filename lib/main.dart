import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:promptly/controllers/app_bindings.dart';
import 'package:promptly/in_app_purchase/purchase_controller.dart';
import 'package:promptly/in_app_purchase/store_config.dart';
import 'package:promptly/services/firebase_configuration/RemoteConfigService.dart';
import 'package:promptly/services/language_service.dart';
import 'package:promptly/utils/AppRoutes.dart';
import 'package:promptly/utils/AppTheme.dart';
import 'data/creations_store.dart';
import 'injection.dart';
import 'network/api_client.dart';

Future<void> main() async {
  // Preserve native splash until we manually remove it
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await CreationsStore().init();
  ApiClient.instance.init();
  configureDependencies();
  // 1. Core System UI Configuration
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 2. Initialize Critical Services
  Get.put(LocaleController());

  final remoteConfig = RemoteConfigService();
  await Get.putAsync(() => remoteConfig.init());
  Get.find<RemoteConfigService>().applyAdsSettings();

  // 3. Initialize RevenueCat + register PurchaseController globally
  //    permanent: true ensures Get.find<PurchaseController>() works everywhere
  try {
    await configureStore();
  } catch (e) {
    debugPrint('[IAP] configureStore error: $e');
  }
  final purchaseCtrl = Get.put(PurchaseController(), permanent: true);
  try {
    await purchaseCtrl.checkPurchasesStatus();
  } catch (e) {
    debugPrint('[IAP] checkPurchasesStatus error: $e');
  }

  runApp(const PromptlyApp());
}
class PromptlyApp extends StatelessWidget {
  const PromptlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with Obx so the whole app reacts to language changes

      // final LocaleController lc = Get.find();

      return ScreenUtilInit(
        designSize: const Size(1290, 2796),
        minTextAdapt: true,
        splitScreenMode: false,
        child: GetMaterialApp(
          title: 'Promptly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,

          // Now this reacts to .obs changes!
          // locale: lc.locale.value,
          //
          // supportedLocales: LanguageService.supportedLocales,
          // localizationsDelegates: const [
          //   AppLocalizations.delegate,
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          //   GlobalCupertinoLocalizations.delegate,
          // ],
          initialBinding: AppBindings(),
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.pages,
          // onGenerateRoute: AppRoutes.splash,
        ),
      );

  }
}
