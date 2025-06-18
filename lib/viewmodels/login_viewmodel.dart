import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/fcm_service.dart';
import '../repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final _repo = AuthRepository();
  bool isLoading = false;
  String? error;

  // Obtener el usuario actual
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Comprobar si hay un usuario autenticado
  bool get isAuthenticated => currentUser != null;

  Future<User?> login(String email, String pass) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final cred = await _repo.login(email, pass);
      isLoading = false; 
      notifyListeners();
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
      isLoading = false;
      notifyListeners();
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

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (e) {
      error = 'Error al cerrar sesión';
      notifyListeners();
    }
  }

  // Obtener el stream de cambios de autenticación
  Stream<User?> get authStateChanges => _repo.authState;
}
