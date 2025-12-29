import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nice_ayurvedic_app/models/cart_item.dart';
import 'package:nice_ayurvedic_app/screens/cart_screen.dart';
import 'package:nice_ayurvedic_app/checkout/checkout_flow.dart';
import 'package:nice_ayurvedic_app/screens/orders_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<CartItem> cartItems = [];
  final TextEditingController _searchController = TextEditingController();

  String _userName = 'Guest';
  String _userPhone = '';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.all_inclusive, 'color': Color(0xFF4CAF50)},
    {'name': 'Herbs', 'icon': Icons.eco, 'color': Color(0xFF8BC34A)},
    {'name': 'Oils', 'icon': Icons.water_drop, 'color': Color(0xFF2196F3)},
    {'name': 'Churna', 'icon': Icons.kitchen, 'color': Color(0xFFFF9800)},
    {'name': 'Tablets', 'icon': Icons.medication, 'color': Color(0xFFF44336)},
    {'name': 'Personal', 'icon': Icons.spa, 'color': Color(0xFF9C27B0)},
    {'name': 'Syrups', 'icon': Icons.local_drink, 'color': Color(0xFF00BCD4)},
    {'name': 'Cosmetic', 'icon': Icons.face, 'color': Color(0xFF795548)},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userPhone = user.phoneNumber ?? '';
      });
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _userName = data?['name'] ?? (_userPhone.isNotEmpty ? _userPhone : 'Guest');
        });
      } else {
        setState(() {
          _userName = _userPhone.isNotEmpty ? _userPhone : 'Guest';
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF2C5530)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NICE AYURVEDIC',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Color(0xFF2C5530),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Welcome, $_userName',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFF2C5530)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(cartItems: cartItems),
                    ),
                  );
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartItems.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Search Bar with Clear Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Icon(Icons.search, color: Color(0xFF2C5530), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search herbs, oils, medicines...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                      onPressed: _clearSearch,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // Promo Banner
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Color(0xFF2C5530), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '30% OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'On all Ayurvedic products',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            // Shop Now functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Explore all products!')),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'Shop Now',
                              style: TextStyle(
                                color: Color(0xFF2C5530),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // Categories Horizontal List
          Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['name'];
                      if (_searchQuery.isNotEmpty) {
                        _clearSearch(); // Clear search when category selected
                      }
                    });
                  },
                  child: Container(
                    width: 65,
                    margin: EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: isSelected ? category['color'] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            category['icon'] as IconData,
                            color: isSelected ? Colors.white : category['color'],
                            size: 22,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? category['color'] : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Filter Status
          if (_selectedCategory != 'All' || _searchQuery.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_alt, size: 16, color: Colors.blue[700]),
                  SizedBox(width: 6),
                  Text(
                    _searchQuery.isNotEmpty 
                        ? 'Searching "$_searchQuery"' 
                        : _selectedCategory,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _clearSearch();
                      });
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 10),

          // Featured Products Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5530),
                  ),
                ),
                Text(
                  '$_selectedCategory',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Products Grid with Filtering
          Expanded(
            child: _buildProductsGrid(),
          ),
        ],
      ),

      floatingActionButton: cartItems.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(bottom: 70),
              child: FloatingActionButton.extended(
                backgroundColor: Color(0xFF2C5530),
                elevation: 3,
                icon: Icon(Icons.shopping_cart_checkout, size: 20),
                label: Text(
                  'CHECKOUT (${cartItems.length})',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutFlow(
                        cartItems: cartItems,
                        customerNumber: _userPhone,
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }

  // ✅ Drawer (unchanged)
  Widget _buildDrawer() {
  return Drawer(
    width: MediaQuery.of(context).size.width * 0.60, // 75% width (half screen)
    backgroundColor: Colors.white,
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C5530), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF2C5530),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _userPhone.isNotEmpty ? _userPhone : 'Not logged in',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
_buildDrawerItem(Icons.home_filled, 'Home', () => Navigator.pop(context), true),
_buildDrawerItem(Icons.person_outline, 'My Profile', () => _showComingSoon('Profile')),
_buildDrawerItem(
  Icons.shopping_bag_outlined, 
  'My Orders', 
  () {
    Navigator.pop(context); // Close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrdersScreen()),
    );
  },
),
_buildDrawerItem(Icons.favorite_border, 'Wishlist', () => _showComingSoon('Wishlist')),
          
          // Divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(thickness: 1, color: Colors.grey[200]),
          ),
          
          _buildDrawerItem(Icons.logout, 'Logout', () {
            _auth.signOut();
            Navigator.popUntil(context, (route) => route.isFirst);
          }),
          
          // Extra spacing at bottom
          SizedBox(height: 40),
        ],
      ),
    ),
  );
}

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, [bool isSelected = false]) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Color(0xFF2C5530) : Colors.grey[700],
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Color(0xFF2C5530) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      trailing: isSelected ? Icon(Icons.chevron_right, color: Color(0xFF2C5530), size: 20) : null,
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: Color(0xFF2C5530),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ✅ Updated Products Grid with Category & Search Filtering
  Widget _buildProductsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF2C5530)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_outlined, size: 60, color: Colors.grey[300]),
                SizedBox(height: 12),
                Text(
                  'No products available',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final allProducts = snapshot.data!.docs;
        final filteredProducts = _filterProducts(allProducts);

        if (filteredProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty 
                      ? 'No products found for "$_searchQuery"'
                      : 'No products in $_selectedCategory category',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _clearSearch();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2C5530),
                  ),
                  child: Text('Show All Products', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(12),
          itemCount: filteredProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.48,
          ),
          itemBuilder: (context, index) {
            final data = filteredProducts[index].data() as Map<String, dynamic>;
            return _buildProductCard(data, filteredProducts[index].id);
          },
        );
      },
    );
  }

  // ✅ Category & Search Filter Logic
  List<QueryDocumentSnapshot> _filterProducts(List<QueryDocumentSnapshot> allProducts) {
    return allProducts.where((product) {
      final data = product.data() as Map<String, dynamic>;
      final productName = (data['name'] ?? '').toLowerCase();
      final productCategory = (data['category'] ?? '').toString();
      
      // Category filter
      bool categoryMatch = _selectedCategory == 'All' || 
                          productCategory.toLowerCase() == _selectedCategory.toLowerCase();
      
      // Search filter
      bool searchMatch = _searchQuery.isEmpty || 
                        productName.contains(_searchQuery) ||
                        productCategory.toLowerCase().contains(_searchQuery);
      
      return categoryMatch && searchMatch;
    }).toList();
  }

  // Product Card & Cart functions (unchanged)
  Widget _buildProductCard(Map<String, dynamic> data, String productId) {
    final bool isOutOfStock = (data['stock'] ?? 0) <= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              color: Colors.grey[100],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: data['imageUrl']?.isNotEmpty == true
                      ? Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2C5530),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) =>
                              Center(child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 40)),
                        )
                      : Center(child: Icon(Icons.spa, color: Color(0xFF2C5530), size: 40)),
                ),
                if (isOutOfStock)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF2C5530).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (data['category'] ?? 'General').toUpperCase(),
                          style: TextStyle(fontSize: 8, color: Color(0xFF2C5530), fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        data['name'] ?? 'Product Name',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[800], height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${(data['price'] ?? 0).toInt()}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C5530)),
                          ),
                          SizedBox(width: 6),
                          if ((data['originalPrice'] ?? 0) > 0)
                            Text(
                              '₹${(data['originalPrice'] ?? 0).toInt()}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500], decoration: TextDecoration.lineThrough),
                            ),
                          Spacer(),
                          Text(
                            '${data['stock'] ?? 0} left',
                            style: TextStyle(
                              fontSize: 10,
                              color: isOutOfStock ? Colors.red : Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: OutlinedButton(
                          onPressed: isOutOfStock ? null : () => _addToCart(data, productId),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isOutOfStock ? Colors.grey[300]! : Color(0xFF2C5530), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_shopping_cart, size: 14, color: isOutOfStock ? Colors.grey[400] : Color(0xFF2C5530)),
                              SizedBox(width: 4),
                              Text(
                                'ADD TO CART',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOutOfStock ? Colors.grey[400] : Color(0xFF2C5530)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: isOutOfStock ? null : () => _buyNowDirect(data, productId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOutOfStock ? Colors.grey[300] : Color(0xFF2C5530),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: EdgeInsets.zero,
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flash_on, size: 14, color: isOutOfStock ? Colors.grey[500] : Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'BUY NOW',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOutOfStock ? Colors.grey[500] : Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Map<String, dynamic> data, String productId) {
    setState(() {
      final index = cartItems.indexWhere((e) => e.id == productId);
      if (index >= 0) {
        cartItems[index].quantity++;
      } else {
        cartItems.add(
          CartItem(
            id: productId,
            name: data['name'] ?? 'Product',
            imageUrl: data['imageUrl'] ?? '',
            price: (data['price'] ?? 0).toDouble(),
            quantity: 1,
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text('${data['name']} added to cart', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: Color(0xFF2C5530),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _buyNowDirect(Map<String, dynamic> data, String productId) {
    final item = CartItem(
      id: productId,
      name: data['name'] ?? 'Product',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: 1,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutFlow(
          cartItems: [item],
          customerNumber: _userPhone.isNotEmpty ? _userPhone : 'Unknown',
        ),
      ),
    );
  }
}
