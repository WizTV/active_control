import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign up method
  Future<User> signup(String email, String password, {String? displayName}) async {
    try {
      final authCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authCredential.user != null) {
        // Optionally set display name
        if (displayName != null && displayName.trim().isNotEmpty) {
          try {
            await authCredential.user!.updateDisplayName(displayName.trim());
            await authCredential.user!.reload();
          } catch (_) {}
        }
        // Return the current (possibly updated) user
        return _auth.currentUser!;
      } else {
        throw Exception('Signup failed. User is null.');
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password provided is too weak.');
        case 'email-already-in-use':
          throw Exception('The account already exists for that email.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        default:
          throw Exception('An unknown error occurred: ${e.message}');
      }
    } catch (e) {
      // Handle other exceptions
      throw Exception('An error occurred during signup: $e');
    }
  }

  // Login method
  Future<User> login(String email, String password) async {
    try {
      final authCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authCredential.user != null) {
        // User is successfully logged in
        return authCredential.user!;
      } else {
        throw Exception('Login failed. User is null.');
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found for that email.');
        case 'wrong-password':
          throw Exception('Wrong password provided.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        default:
          throw Exception('An unknown error occurred: ${e.message}');
      }
    } catch (e) {
      // Handle other exceptions
      throw Exception('An error occurred during login: $e');
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Also sign out from GoogleSignIn to ensure the account chooser
      // appears next time the user tries to sign in with Google.
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
    } catch (e) {
      throw Exception('An error occurred during logout: $e');
    }
  }

  // Get the current user
  User? getCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (e) {
      throw Exception('An error occurred while fetching the current user: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found for that email.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        default:
          throw Exception('An unknown error occurred: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred while resetting the password: $e');
    }
  }

  // Google Sign-In method
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the Google Sign-In authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Make sure we have at least an idToken (required by Firebase on some platforms)
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw Exception('Google authentication failed: no idToken or accessToken returned.\n'
        'On Android ensure Play Services are available and your SHA keys are configured in Firebase.');
      }
      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Reload user to ensure displayName and other fields are populated
      try {
        await userCredential.user?.reload();
      } catch (_) {}

      return _auth.currentUser;
    } catch (e) {
      // Give more specific error messages when possible
      if (e is FirebaseAuthException) {
        throw Exception('FirebaseAuth error during Google Sign-In: ${e.message}');
      }
      throw Exception('Google Sign-In failed: $e');
    }
  }
}