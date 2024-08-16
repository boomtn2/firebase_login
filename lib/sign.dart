import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_4_login/error.dart';
import 'error/code_error_firebase_auth.dart';

Future<UserCredential?> _authenticateWithEmail({
  required String emailAddress,
  required String password,
  required Future<UserCredential> Function() authMethod,
}) async {
  try {
    return await authMethod();
  } on FirebaseAuthException catch (e) {
    throw ErorrBase(
        code: e.code, message: authErrorMessagesVI[e.code] ?? 'Unknown error');
  } catch (e) {
    throw ErorrBase(code: '0', message: 'unknown-error');
  }
}

Future<UserCredential?> createUser(String emailAddress, String password) {
  return _authenticateWithEmail(
    emailAddress: emailAddress,
    password: password,
    authMethod: () => FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    ),
  );
}

Future<UserCredential?> signInWithEmailAndPass(
    String emailAddress, String password) {
  return _authenticateWithEmail(
    emailAddress: emailAddress,
    password: password,
    authMethod: () => FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress,
      password: password,
    ),
  );
}

Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    throw ErorrBase(
        code: 'google-sign-in-failed', message: 'Google sign-in failed');
  }
}
