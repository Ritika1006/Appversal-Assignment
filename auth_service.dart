import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up (email/password). Also creates a user document with role.
  /// Role rule: if email endsWith '@admin.com' -> role = 'admin' else 'user'
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    final role = email.toLowerCase().endsWith('@admin.com') ? 'admin' : 'user';

    final userDoc = {
      'uid': user.uid,
      'name': name,
      'email': email,
      'role': role,
      'interestedEvents': [],
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).set(userDoc);
    return user;
  }

  /// Sign in with email/password
  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  /// Sign out
  Future<void> signOut() async => await _auth.signOut();

  /// Auth state stream
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Get user profile document
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return snap.data();
  }
}
