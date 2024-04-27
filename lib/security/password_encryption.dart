import 'package:encrypt/encrypt.dart';

class PasswordEncryption {
  static final key = Key.fromLength(32);
  static final iv = IV.fromLength(16);

  static String encryptPassword(String password) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  static String decryptPassword(String password) {
    final encrypter = Encrypter(AES(key));
    final encryptedPassword = Encrypted.fromBase64(password);
    final decrypted = encrypter.decrypt(encryptedPassword, iv: iv);
    return decrypted;
  }
}
