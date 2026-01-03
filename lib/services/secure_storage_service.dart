import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Secure storage service for PIN authentication and encrypted data storage
/// Implements security best practices per OWASP MASVS-STORAGE
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const _pinHashKey = 'user_pin_hash';
  static const _pinSaltKey = 'user_pin_salt';
  static const _isPinSetKey = 'is_pin_set';
  static const _failedAttemptsKey = 'failed_attempts';
  static const _lockoutTimeKey = 'lockout_time';

  // Security constants
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 5);

  /// Check if PIN is already set
  static Future<bool> isPinSet() async {
    final value = await _storage.read(key: _isPinSetKey);
    return value == 'true';
  }

  /// Set a new PIN (hashed with salt)
  static Future<void> setPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      throw ArgumentError('PIN must be 4-6 digits');
    }

    // Generate a random salt
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hashedPin = _hashPin(pin, salt);

    await _storage.write(key: _pinHashKey, value: hashedPin);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _isPinSetKey, value: 'true');
    await _resetFailedAttempts();
  }

  /// Verify PIN with rate limiting
  static Future<PinVerificationResult> verifyPin(String pin) async {
    // Check if locked out
    final lockoutTime = await _getLockoutTime();
    if (lockoutTime != null) {
      final remaining = lockoutTime.difference(DateTime.now());
      if (remaining.isNegative) {
        await _resetFailedAttempts();
      } else {
        return PinVerificationResult(
          success: false,
          isLockedOut: true,
          lockoutRemainingSeconds: remaining.inSeconds,
        );
      }
    }

    final storedHash = await _storage.read(key: _pinHashKey);
    final salt = await _storage.read(key: _pinSaltKey);

    if (storedHash == null || salt == null) {
      return PinVerificationResult(
        success: false,
        errorMessage: 'PIN not set',
      );
    }

    final inputHash = _hashPin(pin, salt);
    final isValid = inputHash == storedHash;

    if (isValid) {
      await _resetFailedAttempts();
      return PinVerificationResult(success: true);
    } else {
      final attempts = await _incrementFailedAttempts();
      final remainingAttempts = maxFailedAttempts - attempts;

      if (remainingAttempts <= 0) {
        await _setLockout();
        return PinVerificationResult(
          success: false,
          isLockedOut: true,
          lockoutRemainingSeconds: lockoutDuration.inSeconds,
        );
      }

      return PinVerificationResult(
        success: false,
        remainingAttempts: remainingAttempts,
      );
    }
  }

  /// Change PIN (requires old PIN verification first)
  static Future<bool> changePin(String oldPin, String newPin) async {
    final result = await verifyPin(oldPin);
    if (!result.success) return false;

    await setPin(newPin);
    return true;
  }

  /// Reset PIN (clears all auth data - use with caution)
  static Future<void> resetPin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.write(key: _isPinSetKey, value: 'false');
    await _resetFailedAttempts();
  }

  /// Store encrypted value
  static Future<void> secureWrite(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read encrypted value
  static Future<String?> secureRead(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete encrypted value
  static Future<void> secureDelete(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all secure storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Private helper methods
  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<int> _incrementFailedAttempts() async {
    final current = await _getFailedAttempts();
    final newCount = current + 1;
    await _storage.write(key: _failedAttemptsKey, value: newCount.toString());
    return newCount;
  }

  static Future<int> _getFailedAttempts() async {
    final value = await _storage.read(key: _failedAttemptsKey);
    return int.tryParse(value ?? '0') ?? 0;
  }

  static Future<void> _resetFailedAttempts() async {
    await _storage.write(key: _failedAttemptsKey, value: '0');
    await _storage.delete(key: _lockoutTimeKey);
  }

  static Future<void> _setLockout() async {
    final lockoutEnd = DateTime.now().add(lockoutDuration);
    await _storage.write(
      key: _lockoutTimeKey,
      value: lockoutEnd.toIso8601String(),
    );
  }

  static Future<DateTime?> _getLockoutTime() async {
    final value = await _storage.read(key: _lockoutTimeKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }
}

/// Result of PIN verification
class PinVerificationResult {
  final bool success;
  final bool isLockedOut;
  final int? lockoutRemainingSeconds;
  final int? remainingAttempts;
  final String? errorMessage;

  PinVerificationResult({
    required this.success,
    this.isLockedOut = false,
    this.lockoutRemainingSeconds,
    this.remainingAttempts,
    this.errorMessage,
  });
}
