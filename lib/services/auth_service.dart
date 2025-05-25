import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential> signIn(String email, String pass) =>
    _auth.signInWithEmailAndPassword(email: email, password: pass);

  Future<UserCredential> signUp(String email, String pass) =>
    _auth.createUserWithEmailAndPassword(email: email, password: pass);

  Future<void> signOut() => _auth.signOut();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
