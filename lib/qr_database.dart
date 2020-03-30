import 'dart:math';
import 'package:encrypt/encrypt.dart';

final MAX_DEMO_NUMBER = 50000;
final MIN_DEMO_NUMBER = 50000;
final ENCRYPTER_SECRET = 'SOME RANDOM 32 CHARACTER STRING.';

Encrypter _getEncrypter() {
  final key = Key.fromUtf8(ENCRYPTER_SECRET);
  return Encrypter(AES(key));
}

String getNewQrCode() {
  final iv = IV.fromLength(16);
  final encrypter = _getEncrypter();

  Random random = new Random();
  int randomNumber = random.nextInt(MAX_DEMO_NUMBER) + MIN_DEMO_NUMBER;
  final text = randomNumber.toString();

  final encrypted = encrypter.encrypt(text, iv: iv);
  return encrypted.base64;
}

bool validateQrCode(String encryptedText) {
  try {
    final iv = IV.fromLength(16);
    final encrypter = _getEncrypter();

    final encrypted = Encrypted.from64(encryptedText);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    final number = int.parse(decrypted);
    return number > MIN_DEMO_NUMBER &&
        number <= (MAX_DEMO_NUMBER + MIN_DEMO_NUMBER);
  } catch (e) {
    return false;
  }
}
