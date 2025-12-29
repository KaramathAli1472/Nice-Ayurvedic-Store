import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nice_ayurvedic_app/models/cart_item.dart';
import 'package:nice_ayurvedic_app/screens/home_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Orders')),
        body: Center(child: Text('Please login to view orders')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C5530)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.receipt_long, color: Color(0xFF2C5530)),
            SizedBox(width: 12),
            Text(
              'My Orders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C5530),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .where('customerNumber', isEqualTo: user.phoneNumber ?? '')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF2C5530)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyOrders();
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              return _buildOrderCard(orderData, orders[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Your orders will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            ),
            icon: Icon(Icons.shopping_bag),
            label: Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2C5530),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> orderData, String orderId) {
    final itemsCount = (orderData['items'] as List?)?.length ?? 0;
    final total = (orderData['total'] ?? 0).toDouble();
    final status = orderData['status'] ?? 'pending';
    final timestamp = (orderData['createdAt'] as Timestamp?)?.toDate();
    final dateStr = timestamp != null 
        ? '${_formatDate(timestamp)} ${_formatTime(timestamp)}'
        : 'Unknown';

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmed';
        statusIcon = Icons.check_circle;
        break;
      case 'shipped':
        statusColor = Colors.blue;
        statusText = 'Shipped';
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        statusColor = Colors.green[700]!;
        statusText = 'Delivered';
        statusIcon = Icons.delivery_dining;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Processing';
        statusIcon = Icons.schedule;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${orderData['orderId'] ?? orderId}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5530),
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            Divider(height: 24),
            
            // Items & Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$itemsCount items'),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5530),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showOrderDetails(context, orderData),
                    icon: Icon(Icons.visibility),
                    label: Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF2C5530)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reorder(orderData),
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Reorder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C5530),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${orderData['status'] ?? 'N/A'}'),
              Text('Total: ₹${(orderData['total'] ?? 0).toStringAsFixed(0)}'),
              Text('Payment: ${orderData['payment'] ?? 'N/A'}'),
              Text('Shipping: ${orderData['shipping'] ?? 'N/A'}'),
              SizedBox(height: 12),
              Text('Address: ${orderData['address'] ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _reorder(Map<String, dynamic> orderData) {
    final items = orderData['items'] as List<dynamic>? ?? [];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reordering ${items.length} items...'),
        backgroundColor: Color(0xFF2C5530),
        action: SnackBarAction(
          label: 'Go to Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
            // Navigate to cart with reordered items
          },
        ),
      ),
    );
  }
}
