import 'package:flutter/material.dart';
import 'package:nice_ayurvedic_app/models/cart_item.dart';
import 'package:nice_ayurvedic_app/checkout/checkout_flow.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  
  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get _totalAmount {
    return widget.cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _updateQuantity(CartItem item, int newQuantity) {
    setState(() {
      final index = widget.cartItems.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        if (newQuantity <= 0) {
          widget.cartItems.removeAt(index);
        } else {
          widget.cartItems[index] = CartItem(
            id: item.id,
            name: item.name,
            imageUrl: item.imageUrl,
            price: item.price,
            quantity: newQuantity,
          );
        }
      }
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      widget.cartItems.removeWhere((e) => e.id == item.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed from cart'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C5530)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Cart',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Color(0xFF2C5530),
              ),
            ),
            Text(
              '${widget.cartItems.length} items',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: widget.cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),
                
                // Total & Checkout Section
                _buildCheckoutSection(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, size: 18),
            label: Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2C5530),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Colors.grey[100]),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            Icon(Icons.spa, color: Color(0xFF2C5530), size: 30),
                      )
                    : Icon(Icons.spa, color: Color(0xFF2C5530), size: 30),
              ),
            ),
            SizedBox(width: 12),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C5530),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Increase/Decrease Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _updateQuantity(item, item.quantity - 1),
                      icon: Icon(Icons.remove_circle_outline, 
                                size: 24, color: Colors.red[400]),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5530),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _updateQuantity(item, item.quantity + 1),
                      icon: Icon(Icons.add_circle_outline, 
                                size: 24, color: Color(0xFF4CAF50)),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Remove Item
                TextButton.icon(
                  onPressed: () => _removeItem(item),
                  icon: Icon(Icons.delete_outline, size: 16, color: Colors.red[600]),
                  label: Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${widget.cartItems.length} items)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '₹${_totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C5530),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.cartItems.isEmpty 
                  ? null 
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutFlow(
                            cartItems: widget.cartItems,
                            customerNumber: '', // Will be passed from HomeScreen
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2C5530),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'PROCEED TO CHECKOUT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
