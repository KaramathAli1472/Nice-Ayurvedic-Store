import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // ✅ LoginScreen import

// ✅ Firebase initialize BEFORE app starts
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NiceAyurvedicStore());
}

class NiceAyurvedicStore extends StatelessWidget {
  const NiceAyurvedicStore({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nice Ayurvedic Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C5530),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      // ✅ Directly start with LoginScreen
      home: const LoginScreen(),
    );
  }
}
