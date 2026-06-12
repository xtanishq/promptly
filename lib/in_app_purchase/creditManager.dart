import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seaart_ai/screen/common_screen/constant.dart';

class CreditsManager {
  final storage = const FlutterSecureStorage();

  getUserCredits() async {
    String? creditsString = await storage.read(key: uuid1);
    return creditsString != null ? int.parse(creditsString) : 0;
  }

  Future<void> saveUserCredits(int credits) async {
    await storage.write(key: uuid1, value: credits.toString());
  }
}
