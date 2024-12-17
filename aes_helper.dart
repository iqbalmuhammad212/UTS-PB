import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {

  static String _normalizeKey(String key) {
    return key.padRight(16, '0').substring(0, 16);
  }

  static String encryptText(String plainText, String key) {
    final normalizedKey = _normalizeKey(key);
    final encryptionKey = encrypt.Key.fromUtf8(normalizedKey);
    final iv = encrypt.IV.fromLength(16); 
    final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return "${encrypted.base64}:${iv.base64}"; 
  }

  static String decryptText(String encryptedText, String key) {
    final parts = encryptedText.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Invalid encrypted text format');
    }

    final normalizedKey = _normalizeKey(key);
    final encryptionKey = encrypt.Key.fromUtf8(normalizedKey);
    final iv = encrypt.IV.fromBase64(parts[1]); 
    final encryptedData = encrypt.Encrypted.fromBase64(parts[0]);
    final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey));

    return encrypter.decrypt(encryptedData, iv: iv);
  }
}
