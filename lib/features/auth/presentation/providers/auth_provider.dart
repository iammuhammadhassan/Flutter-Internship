import 'package:flutter/material.dart';

import '../../../user_profile/data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository, this._userRepository);

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        await _userRepository.saveLoggedInUserDetails(
          uid: user.uid,
          name: user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : _fallbackNameFromEmail(email),
          email: user.email ?? email.trim(),
        );
      }

      return true;
    } on Exception catch (error) {
      _errorMessage = _readableFirebaseError(error.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authRepository.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        await _userRepository.saveLoggedInUserDetails(
          uid: user.uid,
          name: name.trim(),
          email: user.email ?? email.trim(),
        );
      }

      return true;
    } on Exception catch (error) {
      _errorMessage = _readableFirebaseError(error.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() => _authRepository.signOut();

  String _fallbackNameFromEmail(String email) {
    final String value = email.trim();
    return value.contains('@') ? value.split('@').first : value;
  }

  String _readableFirebaseError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found for this email.';
    }
    if (error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }
    if (error.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (error.contains('weak-password')) {
      return 'Password is too weak.';
    }
    if (error.contains('network-request-failed')) {
      return 'Network error. Check your connection.';
    }
    return error.replaceFirst('Exception: ', '');
  }
}
