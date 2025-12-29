import 'package:flutter/material.dart';
import '../../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final String customerNumber; // 🔹 added

  const CartScreen({super.key, required this.cartItems, required this.customerNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer Number: $customerNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...cartItems.map((item) {
          return ListTile(
            title: Text(item.name),
            subtitle: Text('₹${item.price} x ${item.quantity}'),
            trailing: Text('₹${item.price * item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ],
    );
  }
}
