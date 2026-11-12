/// Kumpulan fungsi validasi dan sanitasi input.
///
/// Digunakan untuk memeriksa input pengguna
/// sebelum diproses lebih lanjut.
class Validators {
  Validators._();

  /// Memvalidasi format email.
  static bool isValidEmail(String email) {
    final value = email.trim();

    final regex = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

    return regex.hasMatch(value);
  }

  /// Memeriksa apakah input tidak kosong.
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Memeriksa panjang input.
  static bool hasValidLength(String value, {int min = 1, int max = 100}) {
    final length = value.trim().length;
    return length >= min && length <= max;
  }

  /// Sanitasi karakter HTML berbahaya.
  static String sanitize(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .trim();
  }

  /// Validasi teks.
  static String? validateText(
    String? value, {
    String fieldName = 'Field',
    int minLength = 1,
    int maxLength = 100,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }

    if (!hasValidLength(value, min: minLength, max: maxLength)) {
      return '$fieldName harus antara '
          '$minLength-$maxLength karakter';
    }

    return null;
  }

  /// Validasi email.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    if (!isValidEmail(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  /// Validasi nomor telepon 10-13 digit.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    final phone = value.trim();

    if (!RegExp(r'^\d{10,13}$').hasMatch(phone)) {
      return 'Nomor telepon harus 10-13 digit angka';
    }

    return null;
  }

  /// Validasi URL dengan awalan HTTP atau HTTPS.
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL tidak boleh kosong';
    }

    final uri = Uri.tryParse(value.trim());

    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'URL harus diawali http:// atau https://';
    }

    return null;
  }

  /// Validasi password minimal 8 karakter,
  /// huruf kapital, angka, dan simbol.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung huruf kapital';
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password harus mengandung angka';
    }

    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(value)) {
      return 'Password harus mengandung simbol';
    }

    return null;
  }

  /// Validasi nomor telepon dalam bentuk boolean.
  static bool isValidPhone(String phone) {
    return validatePhone(phone) == null;
  }

  /// Validasi URL dalam bentuk boolean.
  static bool isValidUrl(String url) {
    return validateUrl(url) == null;
  }

  /// Validasi password dalam bentuk boolean.
  static bool isValidPassword(String password) {
    return validatePassword(password) == null;
  }
}
