import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C5530),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.spa, size: 90, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'NICE AYURVEDIC STORE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginWithEmail,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login with Email'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _continueAsGuest,
                    child: const Text('Continue as Guest'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EMAIL LOGIN
  Future<void> _loginWithEmail() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _goHome();
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _continueAsGuest() => _goHome();

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}