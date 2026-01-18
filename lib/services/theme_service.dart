import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable value for theme
  ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(true);

  /// Load theme preference from Firestore for the current user
  Future<void> loadThemePreference() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Default to dark mode if no user
        isDarkMode.value = true;
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final isDark = data?['isDarkMode'] as bool? ?? true;
        isDarkMode.value = isDark;
      } else {
        // Default to dark mode for new users
        isDarkMode.value = true;
      }
    } catch (e) {
      // Default to dark mode if there's an error
      isDarkMode.value = true;
    }
  }

  /// Save theme preference to Firestore
  Future<void> setThemeMode(bool isDark) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Try to update existing document first
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'isDarkMode': isDark,
        });
      } on Exception catch (_) {
        // If document doesn't exist, create it
        await _firestore.collection('users').doc(user.uid).set({
          'isDarkMode': isDark,
        }, SetOptions(merge: true));
      }
      
      // Only update local state after successful Firestore save
      isDarkMode.value = isDark;
    } catch (e) {
      print('Error saving theme mode: $e');
      // If save fails, revert the local state
    }
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    await setThemeMode(!isDarkMode.value);
  }
}
