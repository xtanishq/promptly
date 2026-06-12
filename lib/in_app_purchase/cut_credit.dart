import 'package:seaart_ai/ads/AdsVariable.dart';
import 'package:seaart_ai/in_app_purchase/creditManager.dart';
import 'package:seaart_ai/service/sharedPreferencesService.dart';

Future cutCredit(int cutCredit) async {
  var credit = await SharedPreferencesService.getCreditValue('Credit');
  credit -= cutCredit;
  SharedPreferencesService.setCreditValue(credit, 'Credit');
  CreditsManager().saveUserCredits(credit);
  AdsVariable.credits.value = credit;
}

Future addCredit(int addCredit) async {
  var credit = await SharedPreferencesService.getCreditValue('Credit');
  credit += addCredit;
  SharedPreferencesService.setCreditValue(credit, 'Credit');
  CreditsManager().saveUserCredits(credit);
  AdsVariable.credits.value = credit;
}
