import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityHelper {
  // Şifreleme için kullanılacak gizli anahtar (Salt/Pepper)
  // Bunu prodüksiyonda daha güvenli saklamak gerekir ama yerel db için yeterlidir.
  static const String _secretKey = "NotlarimAppSecretKey_2024";

  /// Şifreyi SHA-256 ile hashler
  static String hashPassword(String password) {
    // Şifre + Gizli Anahtar birleştirilir (Tuzlama işlemi)
    var bytes = utf8.encode(password + _secretKey);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
