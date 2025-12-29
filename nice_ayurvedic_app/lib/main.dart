import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // ✅ Changed to login_screen.dart

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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // ✅ 2 seconds ke baad LoginScreen par jao
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(), // ✅ Changed to LoginScreen
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C5530),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.spa,
                size: 70,
                color: Color(0xFF2C5530),
              ),
            ),
            
            const SizedBox(height: 30),
            
            const Text(
              'NICE AYURVEDIC STORE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            
            const SizedBox(height: 10),
            
            const Text(
              '100% Pure • Authentic • Traditional',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 40),
            
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
