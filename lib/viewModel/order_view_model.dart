import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../global/global_instances.dart';

class OrderViewModel extends ChangeNotifier {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;





  Future<void> placeOrder(List<Map<String, dynamic>> cartItems, double totalAmount) async {
    User? user = _auth.currentUser;
    String address = await commonViewModel.getCurrentLocation();
    int state = 0; // 0: aktif, 1: kuryede, -1: teslim edildi.
    if (user != null) {
      Map<String, dynamic> order = {
        'id': _firestore.collection('orders').doc().id,
        'userId': user.uid,
        'items': cartItems,
        'totalAmount': totalAmount,
        'timestamp': FieldValue.serverTimestamp(),
        'address': address,
        'state': state,
      };

      await _firestore.collection('orders').doc(order['id']).set(order);
    }
  }

  Stream<List<Map<String, dynamic>>> streamActiveOrders() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection("orders")
          .where("state", isEqualTo: 0)
          .where("pharmacyId", isEqualTo: user.uid)
          .snapshots()
          .asyncMap((snapshot) async {
        List<Map<String, dynamic>> orders = [];
        for (var doc in snapshot.docs) {
          // Her bir siparişin kullanıcısının belirlenmesi
          var userData = await _firestore.collection("users").doc(doc["userId"]).get();
          var userName = userData["name"];
          // Sipariş verilerinin alınması ve kullanıcı adının eklenmesi
          var orderData = doc.data() as Map<String, dynamic>;
          orderData["name"] = userName;
          orders.add(orderData);
        }
        return orders;
      });
    } else {
      return Stream.value([]);
    }
  }




  Stream<List<Map<String, dynamic>>> streamPastOrders() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection("orders")
          .where("state", isEqualTo: (-1))
          .where("pharmacyId", isEqualTo: user.uid)
          .snapshots()
          .asyncMap((snapshot) async {
        List<Map<String, dynamic>> orders = [];
        for (var doc in snapshot.docs) {
          // Her bir siparişin kullanıcısının belirlenmesi
          var userData = await _firestore.collection("users").doc(doc["userId"]).get();
          var userName = userData["name"];
          // Sipariş verilerinin alınması ve kullanıcı adının eklenmesi
          var orderData = doc.data() as Map<String, dynamic>;
          orderData["name"] = userName;
          orders.add(orderData);
        }
        return orders;
      });
    } else {
      return Stream.value([]);
    }
  }




  Stream<int> streamActiveOrdersCount() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection("orders")
          .where("state", isEqualTo: 0)
          .where("pharmacyId", isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } else {
      return Stream.value(0);
    }
  }



  Future<void> deliverOrderToRider(String orderId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'state': 1,
      });

    } catch (e) {
      print("Sipariş güncellenirken hata oluştu: $e");
    }
  }

}

