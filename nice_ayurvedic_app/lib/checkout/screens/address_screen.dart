import 'package:flutter/material.dart';

class AddressScreen extends StatelessWidget {
  final Function(String) onSaved;

  const AddressScreen({super.key, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Delivery Address',
        border: OutlineInputBorder(),
      ),
      onChanged: onSaved,
      maxLines: 2,
    );
  }
}
