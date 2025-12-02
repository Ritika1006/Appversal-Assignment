import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

class AuthRepository {
  final FirebaseAuthService _service = FirebaseAuthService();

  Stream<User?> get authState => _service.authStateChanges();
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<User?> signUp({required String name, required String email, required String password}) {
    return _service.signUpWithEmail(name: name, email: email, password: password);
  }

  Future<User?> signIn({required String email, required String password}) {
    return _service.signInWithEmail(email, password);
  }

  Future<void> signOut() => _service.signOut();

  Future<Map<String, dynamic>?> getUserProfile(String uid) => _service.getUserProfile(uid);
}
