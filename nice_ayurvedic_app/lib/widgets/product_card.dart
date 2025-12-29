import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
  });

  void _showAddToCartDialog(BuildContext context, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nice Ayurvedic Store'),
        content: Text('Add "$productName" to your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added $productName to cart'),
                  backgroundColor: const Color(0xFF2C5530),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5530),
            ),
            child: const Text(
              'Add to Cart',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image - FIXED HEIGHT
          Container(
            height: 100,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              color: Colors.grey,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF2C5530),
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.medical_services,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.medical_services,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ),
          
          // Product Details - FIXED PADDING
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Name - SHORT
                      Text(
                        name.length > 22 ? '${name.substring(0, 22)}...' : name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 3),
                      
                      // Category
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // Price
                      Text(
                        '₹ ${price.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  // Add to Cart Button - SMALL
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddToCartDialog(context, name);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5530),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
