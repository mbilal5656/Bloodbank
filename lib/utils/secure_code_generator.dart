import 'dart:math';

class SecureCodeGenerator {
  static const String _uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
  static const String _digits = '0123456789';
  static const String _specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  /// Generates a secure code with minimum 8 characters containing:
  /// - At least 2 uppercase letters
  /// - At least 2 lowercase letters
  /// - At least 2 digits
  /// - At least 2 special characters
  static String generateSecureCode({int length = 12}) {
    if (length < 8) length = 8;

    final random = Random.secure();
    final buffer = StringBuffer();

    // Ensure minimum requirements
    buffer.write(_getRandomChars(_uppercaseLetters, 2, random));
    buffer.write(_getRandomChars(_lowercaseLetters, 2, random));
    buffer.write(_getRandomChars(_digits, 2, random));
    buffer.write(_getRandomChars(_specialChars, 2, random));

    // Fill remaining length with random characters
    const allChars =
        _uppercaseLetters + _lowercaseLetters + _digits + _specialChars;
    final remainingLength = length - 8;

    for (int i = 0; i < remainingLength; i++) {
      buffer.write(allChars[random.nextInt(allChars.length)]);
    }

    // Shuffle the final string to make it more random
    final chars = buffer.toString().split('');
    chars.shuffle(random);
    return chars.join();
  }

  /// Generates a blood donation code (8-12 characters)
  static String generateDonationCode() {
    return generateSecureCode(length: 10);
  }

  /// Generates a verification code (8 characters)
  static String generateVerificationCode() {
    return generateSecureCode(length: 8);
  }

  /// Generates a session token (16 characters)
  static String generateSessionToken() {
    return generateSecureCode(length: 16);
  }

  /// Validates if a code meets security requirements
  static bool isValidSecureCode(String code) {
    if (code.length < 8) return false;

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(code);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(code);
    final hasDigits = RegExp(r'[0-9]').hasMatch(code);
    final hasSpecial =
        RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(code);

    return hasUppercase && hasLowercase && hasDigits && hasSpecial;
  }

  /// Gets random characters from a given string
  static String _getRandomChars(String chars, int count, Random random) {
    final result = StringBuffer();
    for (int i = 0; i < count; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }
    return result.toString();
  }

  /// Generates a blood type code (e.g., A+, B-, O+, etc.)
  static String generateBloodTypeCode() {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    final random = Random.secure();
    return bloodTypes[random.nextInt(bloodTypes.length)];
  }

  /// Generates a unique identifier
  static String generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure();
    final randomPart = random.nextInt(10000).toString().padLeft(4, '0');
    return '${timestamp}_$randomPart';
  }
}
