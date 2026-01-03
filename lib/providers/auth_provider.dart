import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

/// Authentication states
enum AuthState {
  unknown,      // Initial state, checking if PIN is set
  unauthenticated, // User needs to login
  needsSetup,   // First time, needs to set PIN
  authenticated, // User is logged in
  lockedOut,    // Too many failed attempts
}

/// Auth provider for managing authentication state
/// Implements secure PIN authentication with rate limiting
class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.unknown;
  int? _remainingAttempts;
  int? _lockoutSecondsRemaining;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get needsSetup => _state == AuthState.needsSetup;
  bool get isLockedOut => _state == AuthState.lockedOut;
  int? get remainingAttempts => _remainingAttempts;
  int? get lockoutSecondsRemaining => _lockoutSecondsRemaining;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  /// Initialize auth state (call on app start)
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isPinSet = await SecureStorageService.isPinSet();
      
      if (isPinSet) {
        _state = AuthState.unauthenticated;
      } else {
        _state = AuthState.needsSetup;
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize auth: $e';
      _state = AuthState.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set PIN for first time setup
  Future<bool> setupPin(String pin, String confirmPin) async {
    _clearError();

    // Validate PIN
    if (pin.length < 4 || pin.length > 6) {
      _errorMessage = 'PIN must be 4-6 digits';
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      _errorMessage = 'PIN must contain only numbers';
      notifyListeners();
      return false;
    }

    if (pin != confirmPin) {
      _errorMessage = 'PINs do not match';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await SecureStorageService.setPin(pin);
      _state = AuthState.authenticated;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to set PIN: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with PIN
  Future<bool> login(String pin) async {
    _clearError();
    _isLoading = true;
    notifyListeners();

    try {
      final result = await SecureStorageService.verifyPin(pin);

      if (result.success) {
        _state = AuthState.authenticated;
        _remainingAttempts = null;
        _lockoutSecondsRemaining = null;
        return true;
      }

      if (result.isLockedOut) {
        _state = AuthState.lockedOut;
        _lockoutSecondsRemaining = result.lockoutRemainingSeconds;
        _errorMessage = 'Too many failed attempts. Try again later.';
      } else {
        _remainingAttempts = result.remainingAttempts;
        _errorMessage = 'Incorrect PIN. ${result.remainingAttempts} attempts remaining.';
      }

      return false;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout (clear authenticated state)
  void logout() {
    _state = AuthState.unauthenticated;
    _remainingAttempts = null;
    _lockoutSecondsRemaining = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Change PIN (requires current PIN)
  Future<bool> changePin(String oldPin, String newPin, String confirmPin) async {
    _clearError();

    if (newPin.length < 4 || newPin.length > 6) {
      _errorMessage = 'New PIN must be 4-6 digits';
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(newPin)) {
      _errorMessage = 'PIN must contain only numbers';
      notifyListeners();
      return false;
    }

    if (newPin != confirmPin) {
      _errorMessage = 'New PINs do not match';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await SecureStorageService.changePin(oldPin, newPin);
      if (!success) {
        _errorMessage = 'Current PIN is incorrect';
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to change PIN: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear lockout (called after lockout timer expires)
  void clearLockout() {
    _state = AuthState.unauthenticated;
    _lockoutSecondsRemaining = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update lockout countdown
  void updateLockoutTimer(int secondsRemaining) {
    _lockoutSecondsRemaining = secondsRemaining;
    if (secondsRemaining <= 0) {
      clearLockout();
    } else {
      notifyListeners();
    }
  }

  void _clearError() {
    _errorMessage = null;
  }
}
