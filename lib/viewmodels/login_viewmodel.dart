import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/fcm_service.dart';
import '../repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final _repo = AuthRepository();
  bool isLoading = false;
  String? error;

  Future<User?> login(String email, String pass) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final cred = await _repo.login(email, pass);
      await FCMService.saveTokenToDatabase();
      return cred.user;
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Error inesperado';
    }
    isLoading = false;
    notifyListeners();
    return null;
  }

  Future<User?> register(String email, String pass) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final cred = await _repo.register(email, pass);
      await FCMService.saveTokenToDatabase();
      return cred.user;
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Error inesperado';
    }
    isLoading = false;
    notifyListeners();
    return null;
  }
}
