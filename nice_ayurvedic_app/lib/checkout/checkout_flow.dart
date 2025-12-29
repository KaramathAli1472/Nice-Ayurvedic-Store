import 'package:flutter/material.dart';
import 'package:nice_ayurvedic_app/models/cart_item.dart';

import 'screens/cart_screen.dart';
import 'screens/address_screen.dart';
import 'screens/shipping_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/confirmation_screen.dart';

class CheckoutFlow extends StatefulWidget {
  final List<CartItem> cartItems;
  final String customerNumber; // 🔹 added customer number

  const CheckoutFlow({
    super.key,
    required this.cartItems,
    required this.customerNumber,
  });

  @override
  State<CheckoutFlow> createState() => _CheckoutFlowState();
}

class _CheckoutFlowState extends State<CheckoutFlow> {
  int _currentStep = 0;

  // 🔹 Shared checkout data
  String address = '';
  String shippingMethod = 'Standard';
  String paymentMethod = 'COD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF2C5530),
      ),
      body: Stepper(
        currentStep: _currentStep,
        type: StepperType.vertical,
        controlsBuilder: (context, details) {
          if (_currentStep == 4) return const SizedBox(); // hide buttons
          return Row(
            children: [
              ElevatedButton(onPressed: details.onStepContinue, child: const Text('Next')),
              const SizedBox(width: 10),
              TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
            ],
          );
        },
        onStepContinue: () {
          if (_currentStep < 4) setState(() => _currentStep++);
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          Step(
            title: const Text('Cart'),
            isActive: _currentStep >= 0,
            content: CartScreen(
              cartItems: widget.cartItems,
              customerNumber: widget.customerNumber, // 🔹 pass number
            ),
          ),
          Step(
            title: const Text('Address'),
            isActive: _currentStep >= 1,
            content: AddressScreen(
              onSaved: (value) {
                address = value;
              },
            ),
          ),
          Step(
            title: const Text('Shipping'),
            isActive: _currentStep >= 2,
            content: ShippingScreen(
              selected: shippingMethod,
              onChanged: (value) {
                shippingMethod = value;
              },
            ),
          ),
          Step(
            title: const Text('Payment'),
            isActive: _currentStep >= 3,
            content: PaymentScreen(
              selected: paymentMethod,
              onChanged: (value) {
                paymentMethod = value;
              },
            ),
          ),
          Step(
            title: const Text('Confirm'),
            isActive: _currentStep >= 4,
            content: ConfirmationScreen(
              cartItems: widget.cartItems,
              address: address,
              shipping: shippingMethod,
              payment: paymentMethod,
              customerNumber: widget.customerNumber, // 🔹 pass number
            ),
          ),
        ],
      ),
    );
  }
}
