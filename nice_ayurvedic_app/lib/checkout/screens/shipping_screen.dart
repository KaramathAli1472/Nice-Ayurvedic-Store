import 'package:flutter/material.dart';

class ShippingScreen extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const ShippingScreen({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile(
          value: 'Standard',
          groupValue: selected,
          onChanged: (v) => onChanged(v.toString()),
          title: const Text('Standard Delivery'),
        ),
        RadioListTile(
          value: 'Express',
          groupValue: selected,
          onChanged: (v) => onChanged(v.toString()),
          title: const Text('Express Delivery'),
        ),
      ],
    );
  }
}
