import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'services/auth_service.dart';
import 'services/firestore_training_service.dart';
import 'services/theme_service.dart';
import 'pages/home_page.dart';
import 'pages/edit_training_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    
    // Load theme preference
    _themeService.loadThemePreference().then((_) {
      setState(() {});
    });
    
    // Listen to theme changes
    _themeService.isDarkMode.addListener(() {
      setState(() {});
    });
    
    final bool loggedIn = AuthService().getCurrentUser() != null;
    // Load trainings from Firestore if user is logged in
    if (loggedIn) {
      FirestoreTrainingService().loadTrainings();
    }
  }

  @override
  void dispose() {
    _themeService.isDarkMode.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = AuthService().getCurrentUser() != null;
    final bool isDarkMode = _themeService.isDarkMode.value;

    // Dark mode colors (original)
    const darkPrimaryColor = Color.fromRGBO(33, 52, 102, 1);
    const darkContainerColor = Color.fromRGBO(28, 43, 84, 1);
    const darkTextColor = Colors.white;

    // Light mode colors (pastel matte light blue)
    const lightPrimaryColor = Color.fromRGBO(200, 220, 245, 1); // Soft pastel light blue
    const lightContainerColor = Color.fromRGBO(220, 235, 255, 1); // Slightly lighter pastel
    const lightTextColor = Color.fromRGBO(30, 50, 100, 1); // Dark blue for good contrast

    final primaryColor = isDarkMode ? darkPrimaryColor : lightPrimaryColor;
    final containerColor = isDarkMode ? darkContainerColor : lightContainerColor;
    final textColor = isDarkMode ? darkTextColor : lightTextColor;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: primaryColor,
      secondary: containerColor,
      onPrimary: textColor,
      onSecondary: textColor,
      onSurface: textColor,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: primaryColor,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
          bodySmall: TextStyle(color: textColor),
          displayLarge: TextStyle(color: textColor),
          displayMedium: TextStyle(color: textColor),
          displaySmall: TextStyle(color: textColor),
          headlineLarge: TextStyle(color: textColor),
          headlineMedium: TextStyle(color: textColor),
          headlineSmall: TextStyle(color: textColor),
          titleLarge: TextStyle(color: textColor),
          titleMedium: TextStyle(color: textColor),
          titleSmall: TextStyle(color: textColor),
          labelLarge: TextStyle(color: textColor),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: textColor,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? darkPrimaryColor : const Color.fromRGBO(100, 130, 210, 1),
            foregroundColor: isDarkMode ? darkTextColor : lightTextColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: primaryColor,
          scrimColor: Colors.transparent,
        ),
        iconTheme: IconThemeData(color: textColor),
        listTileTheme: ListTileThemeData(
          textColor: textColor,
          iconColor: textColor,
        ),
      ),
      home: loggedIn ? const HomePage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/edit-training': (context) => const EditTrainingPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}