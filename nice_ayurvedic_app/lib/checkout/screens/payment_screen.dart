import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const PaymentScreen({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile(
          value: 'COD',
          groupValue: selected,
          onChanged: (v) => onChanged(v.toString()),
          title: const Text('Cash on Delivery'),
        ),
        RadioListTile(
          value: 'Online',
          groupValue: selected,
          onChanged: (v) => onChanged(v.toString()),
          title: const Text('Online Payment'),
        ),
      ],
    );
  }
}
