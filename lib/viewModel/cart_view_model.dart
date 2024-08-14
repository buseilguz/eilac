import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> item) async {
    _cartItems.add(item);
    await _updateCartInFirestore();
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> item) async {
    _cartItems.remove(item);
    await _updateCartInFirestore();
    notifyListeners();
  }

  void clearCart() async {
    _cartItems.clear();
    await _updateCartInFirestore();
    notifyListeners();
  }

  Future<void> _updateCartInFirestore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).update({
        "userCart": _cartItems.map((item) => item["prescription_id"]).toList(),
      });
    }
  }

  int countItem() {
    return _cartItems.length;
  }

  Future<void> loadCartFromFirestore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
      List<dynamic> cartItemIds = userDoc["userCart"] ?? [];
      if (cartItemIds.isNotEmpty) {
        QuerySnapshot prescriptionQuery = await _firestore
            .collection("prescriptions")
            .where(FieldPath.documentId, whereIn: cartItemIds)
            .get();
        _cartItems = prescriptionQuery.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['prescription_id'] = doc.id; // prescription_id'yi belge kimliği olarak ekliyoruz
          return data;
        }).toList();
        notifyListeners();
      }
    }
  }
}
