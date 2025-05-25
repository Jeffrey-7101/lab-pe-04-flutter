import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final _svc = AuthService();

  Future<UserCredential> login(String e, String p) => _svc.signIn(e, p);
  Future<UserCredential> register(String e, String p) => _svc.signUp(e, p);
  Future<void> logout() => _svc.signOut();
  Stream<User?> get authState => _svc.authStateChanges;
}
