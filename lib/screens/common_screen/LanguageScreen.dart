// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../l10n/app_localizations.dart';
// import '../../services/language_service.dart';
//
// class LanguageScreen extends StatelessWidget {
//   const LanguageScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final LocaleController controller = Get.find();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppLocalizations.of(context)!.selectLanguage),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           Expanded(
//             child: ListView.separated(
//               itemCount: LanguageService.supportedLocales.length,
//               separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
//               itemBuilder: (context, index) {
//                 final locale = LanguageService.supportedLocales[index];
//                 final String langName = LanguageService.languageNames[locale.languageCode] ?? "";
//
//                 return Obx(() {
//                   final bool isSelected = controller.locale.value.languageCode == locale.languageCode;
//
//                   return ListTile(
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     leading: _buildFlagPlaceholder(locale.languageCode),
//                     title: Text(
//                       langName,
//                       style: TextStyle(
//                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                         color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
//                       ),
//                     ),
//                     trailing: isSelected
//                         ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
//                         : null,
//                     onTap: () => controller.setLocale(locale),
//                   );
//                 });
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Placeholder for when you add your flags later
//   Widget _buildFlagPlaceholder(String code) {
//     return Container(
//       width: 40,
//       height: 30,
//       decoration: BoxDecoration(
//         color: Colors.white10,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Center(
//         child: Text(code.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
// }