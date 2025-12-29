import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Products Collection
  CollectionReference get productsCollection => _firestore.collection('products');
  
  // Get all products
  Stream<QuerySnapshot> getProducts() {
    return productsCollection.snapshots();
  }
  
  // Add new product (Admin panel se)
  Future<void> addProduct(Map<String, dynamic> productData) async {
    await productsCollection.add(productData);
  }
  
  // Update product
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await productsCollection.doc(id).update(data);
  }
  
  // Delete product
  Future<void> deleteProduct(String id) async {
    await productsCollection.doc(id).delete();
  }
  
  // Upload image to Firebase Storage
  Future<String> uploadProductImage(String path, Uint8List imageBytes) async {
    try {
      final Reference ref = _storage.ref().child('products/$path');
      final UploadTask uploadTask = ref.putData(imageBytes);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}