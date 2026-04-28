import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── GOOGLE ────────────────────────────────────────────────
  static Future<Map<String, String>?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final String? idToken =
      await userCredential.user?.getIdToken();

      return {
        'token': idToken ?? '',
        'provider': 'google',
      };
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  // ─── FACEBOOK ──────────────────────────────────────────────
  static Future<Map<String, String>?> signInWithFacebook() async {
    return null;
  
    // try {
    //   final LoginResult result = await FacebookAuth.instance.login(
    //     permissions: ['email', 'public_profile'],
    //   );
    //
    //   if (result.status != LoginStatus.success) return null;
    //
    //   final OAuthCredential credential =
    //   FacebookAuthProvider.credential(result.accessToken!.tokenString);
    //
    //   final UserCredential userCredential =
    //   await _auth.signInWithCredential(credential);
    //
    //   final String? idToken =
    //   await userCredential.user?.getIdToken();
    //
    //   return {
    //     'token': idToken ?? '',
    //     'provider': 'facebook',
    //   };
    // } catch (e) {
    //   print('Facebook Sign-In error: $e');
    //   return null;
    // }
  }
}