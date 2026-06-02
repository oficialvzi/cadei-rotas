import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioAtual => _auth.currentUser;

  bool get estaCadastrado =>
      _auth.currentUser != null && !_auth.currentUser!.isAnonymous;

  // ── Email/senha — Login ────────────────────────────────────────────────────
  Future<User?> entrarComEmail(String email, String senha) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
    return cred.user;
  }

  // ── Email/senha — Cadastro ─────────────────────────────────────────────────
  Future<User?> cadastrarComEmail(String email, String senha) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    return cred.user;
  }

// ── Google ─────────────────────────────────────────────────────────────────
  Future<User?> entrarComGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: null, // usa o google-services.json automaticamente no Android
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // usuário cancelou

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return cred.user;
  }

  // ── Anônimo (reports sem cadastro) ────────────────────────────────────────
  Future<User?> entrarAnonimo() async {
    if (_auth.currentUser != null) return _auth.currentUser;
    final cred = await _auth.signInAnonymously();
    return cred.user;
  }

  // ── Reset de senha ────────────────────────────────────────────────────────
  Future<void> enviarEmailReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Sair ──────────────────────────────────────────────────────────────────
  Future<void> sair() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
  }
}
