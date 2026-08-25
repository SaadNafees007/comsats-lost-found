import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    // initialize() must be called before authenticate().
    // Wrapping in try/catch handles the case where it was already called.
    try {
      await googleSignIn.initialize();
    } catch (_) {
      // Already initialized — safe to continue.
    }

    // authenticate() presents the Google account picker and returns the
    // signed-in account. Throws if the user cancels or an error occurs.
    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

    // In v7, .authentication is a synchronous getter — no await needed.
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore Google sign-out errors when the user
      // was not signed in with Google.
    }
  }
}
