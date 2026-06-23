import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:promptly/controllers/app_bindings.dart';
import 'package:promptly/in_app_purchase/bloc/purchase_bloc.dart';
import 'package:promptly/in_app_purchase/purchase_repository.dart';
import 'package:promptly/services/firebase_configuration/RemoteConfigService.dart';
import 'package:promptly/services/language_service.dart';
import 'package:promptly/utils/AppRoutes.dart';
import 'package:promptly/utils/AppTheme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/creations_store.dart';
import 'data/prompt_model.dart';
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
  await Supabase.initialize(
    url: 'https://mkpiutvitriyqbasecft.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1rcGl1dHZpdHJpeXFiYXNlY2Z0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxNTg2MjIsImV4cCI6MjA5NTczNDYyMn0.YFOgkkULCc3Jm1DVux7sawNNbf6-lsc63oJCe3ufasA',
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Get.lazyPut(()=>PromptFeedService());


  // 2. Initialize Critical Services
  Get.put(LocaleController());

  final remoteConfig = RemoteConfigService();
  await Get.putAsync(() => remoteConfig.init());
  Get.find<RemoteConfigService>().applyAdsSettings();

  // 3. Initialize RevenueCat, then hydrate the PurchaseBloc (get_it singleton).
  //    configure() MUST run before the bloc is built (it attaches a RevenueCat
  //    customer-info listener). The bloc mirrors state into AdsVariable.
  try {
    await getIt<PurchaseRepository>().configure();
  } catch (e) {
    debugPrint('[IAP] configure error: $e');
  }
  getIt<PurchaseBloc>().add(const PurchaseStarted());

  runApp(const PromptlyApp());
}
class PromptlyApp extends StatelessWidget {
  const PromptlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with Obx so the whole app reacts to language changes

      // final LocaleController lc = Get.find();

      return BlocProvider<PurchaseBloc>.value(
        value: getIt<PurchaseBloc>(),
        child: ScreenUtilInit(
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
      ),
      );

  }
}
class PromptFeedService {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<List<Prompt>> getPrompts() async {
    final appRow = await _supabase
        .from('apps')
        .select('id')
        .eq('slug', 'promptly')
        .maybeSingle();

    if (appRow == null) {
      debugPrint('❌ No app found for slug promptly');
      return [];
    }

    final publicationRow = await _supabase
        .from('app_publications')
        .select('payload')
        .eq('app_id', appRow['id'])
        .eq('is_current', true)
        .maybeSingle();

    if (publicationRow == null) {
      debugPrint('❌ No current publication found for Promptly');
      return [];
    }

    final payload = publicationRow['payload'] as List<dynamic>;

    return payload.map((row) {
      final item = Map<String, dynamic>.from(row as Map);
      return Prompt.fromJson(item);
    }).toList();
  }
}