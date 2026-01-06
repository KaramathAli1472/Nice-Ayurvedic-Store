import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:nice_ayurvedic_app/models/cart_item.dart';
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
  final TextEditingController _searchController = TextEditingController();

  final List<CartItem> cartItems = [];

  String _userName = '';
  String _userPhone = '';
  String _searchQuery = '';

  // 📍 Location
  String _pincode = 'Detecting...';
  String _areaName = '';

  // 🎁 OFFERS
  final List<Map<String, dynamic>> _offers = [
    {
      'title': '30% OFF',
      'subtitle': 'On all Ayurvedic products',
      'color': Color(0xFF2C5530),
      'icon': Icons.local_offer,
      'endTime': 'Ends in 2 days'
    },
    {
      'title': 'FREE Delivery',
      'subtitle': 'On orders above ₹499',
      'color': Color(0xFF2196F3),
      'icon': Icons.local_shipping,
      'endTime': 'Limited time'
    },
    {
      'title': 'BUY 1 GET 1',
      'subtitle': 'Selected herbal products',
      'color': Color(0xFF9C27B0),
      'icon': Icons.card_giftcard,
      'endTime': 'Today only'
    },
    {
      'title': 'NEW ARRIVALS',
      'subtitle': 'Check latest Ayurvedic herbs',
      'color': Color(0xFFFF5722),
      'icon': Icons.new_releases,
      'endTime': 'Just in!'
    },
    {
      'title': 'HOLIDAY SALE',
      'subtitle': 'Up to 50% off on wellness kits',
      'color': Color(0xFF009688),
      'icon': Icons.beach_access,
      'endTime': 'Ends this week'
    },
    {
      'title': 'EXTRA 10% OFF',
      'subtitle': 'For first-time customers',
      'color': Color(0xFFFF9800),
      'icon': Icons.star,
      'endTime': 'Limited offer'
    },
    {
      'title': 'WEEKEND SPECIAL',
      'subtitle': 'Discounts on immunity boosters',
      'color': Color(0xFF3F51B5),
      'icon': Icons.weekend,
      'endTime': 'This weekend only'
    },
    {
      'title': 'BUY 2 GET 1',
      'subtitle': 'On selected herbal teas',
      'color': Color(0xFF795548),
      'icon': Icons.local_cafe,
      'endTime': 'Today only'
    },
    {
      'title': 'FLASH SALE',
      'subtitle': 'Up to 40% off on skincare',
      'color': Color(0xFFE91E63),
      'icon': Icons.flash_on,
      'endTime': 'Next 24 hours'
    },
    {
      'title': 'LOYALTY BONUS',
      'subtitle': 'Extra points on every purchase',
      'color': Color(0xFF4CAF50),
      'icon': Icons.card_membership,
      'endTime': 'Ongoing'
    },
    {
      'title': 'IMMUNITY BOOSTER',
      'subtitle': 'Special offer on herbal supplements',
      'color': Color(0xFF607D8B),
      'icon': Icons.health_and_safety,
      'endTime': 'This month'
    },
    {
      'title': 'SKIN CARE SALE',
      'subtitle': 'Get glowing skin naturally',
      'color': Color(0xFFFF4081),
      'icon': Icons.face,
      'endTime': 'Ends in 3 days'
    },
    {
      'title': 'HERBAL TEA WEEK',
      'subtitle': 'Buy your favorite teas',
      'color': Color(0xFF8BC34A),
      'icon': Icons.emoji_food_beverage,
      'endTime': '7 days only'
    },
    {
      'title': 'STRESS RELIEF',
      'subtitle': 'Special discounts on ashwagandha products',
      'color': Color(0xFF795548),
      'icon': Icons.self_improvement,
      'endTime': 'This week'
    },
    {
      'title': 'DIGITAL COUPON',
      'subtitle': 'Use code AYUR50 for ₹50 off',
      'color': Color(0xFF3F51B5),
      'icon': Icons.confirmation_num,
      'endTime': 'Today only'
    },
  ];

  late final PageController _offerController;
  int _currentOfferIndex = 0;
  int _selectedIndex = 0; // Bottom navigation

  @override
  void initState() {
    super.initState();
    _offerController = PageController();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _loadUserData();
    _initLocation();
    _startOfferAutoSlide();
  }

  // ---------------- USER ----------------
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _userName = data?['name']?.toString() ?? 'User';
        _userPhone = data?['phone']?.toString() ?? '';
      });
    }
  }

  // ---------------- LOCATION ----------------
  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _pincode = 'Set location';
          _areaName = 'GPS off';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _pincode = 'Set location';
          _areaName = 'Permission denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      final place = placemarks.first;

      setState(() {
        _pincode = place.postalCode ?? 'N/A';
        _areaName = place.subLocality?.isNotEmpty == true
            ? place.subLocality!
            : (place.locality ?? 'Unknown');
      });
    } catch (e) {
      setState(() {
        _pincode = 'Set location';
        _areaName = 'Location error';
      });
    }
  }

  // ---------------- OFFER AUTO SLIDE ----------------
  void _startOfferAutoSlide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _currentOfferIndex = (_currentOfferIndex + 1) % _offers.length;
      _offerController.animateToPage(
        _currentOfferIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startOfferAutoSlide();
    });
  }

  // ---------------- ADD TO CART ----------------
  _addToCart(Map<String, dynamic> data, String id) {
    setState(() {
      cartItems.add(
        CartItem(
          id: id,
          name: data['name']?.toString() ?? 'Unknown',
          imageUrl: data['imageUrl']?.toString() ??
              'https://via.placeholder.com/150',
          price: (data['price'] is num ? (data['price'] as num).toDouble() : 0.0),
          quantity: 1,
        ),
      );
    });
  }

  // ---------------- BOTTOM NAV ----------------
  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    const themeGreen = Color(0xFF2C5530);

    final List<Widget> _pages = [
      _homeContent(),
      _cartPage(),
      _ordersPage(),
    ];

    return Scaffold(
      drawer: _drawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          // Fixed Checkout Button
          if (cartItems.isNotEmpty)
            Positioned(
              bottom: 01, // bottom navigation ke upar
              left: 105,
              right: 105,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CheckoutFlow(
                            cartItems: cartItems,
                            customerNumber: _userPhone
                        )
                    ),
                  );
                },
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: themeGreen,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
        ],
      ),
    );
  }

  // ---------------- HOME CONTENT ----------------
  Widget _homeContent() {
    return Column(
      children: [
        _header(),
        Expanded(child: _products()),
      ],
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Expanded(child: _searchBar()),
            ],
          ),
          InkWell(
            onTap: _initLocation,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 4),
                Text(
                  _pincode,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _areaName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _offerSlider(),
        ],
      ),
    );
  }

  Widget _offerSlider() {
    return SizedBox(
      height: 90,
      child: PageView.builder(
        controller: _offerController,
        itemCount: _offers.length,
        itemBuilder: (context, index) {
          final offer = _offers[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: offer['color'] as Color? ?? Colors.green,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(offer['icon'] as IconData? ?? Icons.local_offer,
                    color: Colors.white, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['title']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        offer['subtitle']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer['endTime']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search products',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ---------------- PRODUCTS ----------------
  Widget _products() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: snapshot.data!.docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, i) {
            final data =
                snapshot.data!.docs[i].data() as Map<String, dynamic>? ?? {};
            return _productCard(data, snapshot.data!.docs[i].id);
          },
        );
      },
    );
  }

  Widget _productCard(Map<String, dynamic> data, String id) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                ? Image.network(data['imageUrl'].toString(), fit: BoxFit.cover)
                : const Icon(Icons.spa, size: 50),
          ),
          Text(data['name']?.toString() ?? ''),
          Text('₹${data['price']?.toString() ?? '0'}'),
          ElevatedButton(
            onPressed: () => _addToCart(data, id),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ---------------- CART PAGE ----------------
  Widget _cartPage() {
    return cartItems.isEmpty
        ? const Center(child: Text('Cart is empty'))
        : ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: cartItems.length,
      itemBuilder: (context, i) {
        final item = cartItems[i];
        return ListTile(
          leading: item.imageUrl != null
              ? Image.network(item.imageUrl!, width: 50, height: 50)
              : const Icon(Icons.spa),
          title: Text(item.name ?? ''),
          subtitle: Text('₹${item.price} x ${item.quantity}'),
        );
      },
    );
  }

  // ---------------- ORDERS PAGE ----------------
  Widget _ordersPage() {
    return const Center(child: Text('Orders Page'));
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName),
            accountEmail: Text(_userPhone),
          ),
          ListTile(
            title: const Text('Orders'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () => _auth.signOut(),
          ),
        ],
      ),
    );
  }
}
