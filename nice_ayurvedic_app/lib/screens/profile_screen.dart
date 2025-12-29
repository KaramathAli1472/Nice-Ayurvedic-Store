import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF2C5530),
      ),
      body: const Center(
        child: Text('Profile Screen - Under Development'),
      ),
    );
  }
}