import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nice_ayurvedic_app/models/cart_item.dart';

class ConfirmationScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final String address;
  final String shipping;
  final String payment;
  final String customerNumber; // 🔹 added

  const ConfirmationScreen({
    super.key,
    required this.cartItems,
    required this.address,
    required this.shipping,
    required this.payment,
    required this.customerNumber,
  });

  double get total => cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  Future<void> _placeOrder(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'customerNumber': customerNumber,
        'items': cartItems.map((e) => {
          'id': e.id,
          'name': e.name,
          'price': e.price,
          'quantity': e.quantity,
        }).toList(),
        'address': address,
        'shipping': shipping,
        'payment': payment,
        'total': total,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully ✅')));
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer: $customerNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...cartItems.map((item) => ListTile(
          title: Text(item.name),
          subtitle: Text('Qty: ${item.quantity}'),
          trailing: Text('₹${item.price * item.quantity}'),
        )),
        const Divider(),
        Text('Address:\n$address'),
        const SizedBox(height: 6),
        Text('Shipping: $shipping'),
        Text('Payment: $payment'),
        const Divider(),
        Text('Total: ₹$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _placeOrder(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('PLACE ORDER', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
