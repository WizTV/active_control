import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign up method
  Future<User> signup(String email, String password) async {
    try {
      final authCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authCredential.user != null) {
        // User is successfully signed up
        return authCredential.user!;
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

      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }
}