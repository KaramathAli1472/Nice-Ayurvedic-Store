import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: const Color(0xFF2C5530),
      ),
      body: const Center(
        child: Text('Contact Us Screen - Under Development'),
      ),
    );
  }
}