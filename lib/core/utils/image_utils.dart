import 'package:flutter/foundation.dart';

class ImageUtils {
  static String wrapProxy(String url) {
    if (kIsWeb && url.contains('firebasestorage.googleapis.com')) {
      // Usamos un proxy para saltarnos el bloqueo de CORS en la Web
      return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }
}
