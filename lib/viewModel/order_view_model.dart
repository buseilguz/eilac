import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users_app/global/global_instances.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _orderAddress = [];

  List<Map<String, dynamic>> get orderAddress => _orderAddress;

  Future<void> placeOrder(
      List<Map<String, dynamic>> cartItems,
      double totalAmount, {
        String? pharmacyId,
        String? pharmacyName,
      }) async {
    User? user = _auth.currentUser;
    bool accepted=false;
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
        'pharmacyId': pharmacyId,
        'pharmacyName': pharmacyName,
        'accepted':accepted,
      };

      await _firestore.collection('orders').doc(order['id']).set(order);
    }
  }

  Stream<List<Map<String, dynamic>>> streamActiveOrders() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection("orders")
          .where("userId", isEqualTo: user.uid)
          .where("state", whereIn: [0, 1])
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
    } else {
      return Stream.value([]);
    }
  }



  Stream<List<Map<String, dynamic>>> streamPastOrders() {
    return _firestore
        .collection("orders")
        .where("state", isEqualTo: -1) // -1 olan siparişleri al
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }





  Stream<Position> streamCourierLocation(String courierId) {
    return _firestore.collection('courier_locations')
        .doc(courierId)
        .snapshots()
        .map((snapshot) {
      var data = snapshot.data()!;
      return Position(
        latitude: data['latitude'],
        longitude: data['longitude'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        accuracy: data['accuracy'] ?? 0.0,
        speed: data['speed'] ?? 0.0,
        heading: data['heading'] ?? 0.0,
        altitude: data['altitude'] ?? 0.0,
        altitudeAccuracy: data['altitudeAccuracy'] ?? 0.0,
        headingAccuracy: data['headingAccuracy'] ?? 0.0,
        speedAccuracy: data['speedAccuracy'] ?? 0.0,
      );
    });
  }









  Future<void> loadOrderAddress(String orderId) async {
    try {
      // `orderId`'yi belge ID'si olarak alıyoruz
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();

      if (doc.exists && doc['state'] == 1) {
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;

        // Adres bilgisini koordinatlara dönüştürme
        final coordinates = await _getCoordinatesFromAddress(orderData['address']);
        if (coordinates != null) {
          orderData['latitude'] = coordinates['latitude'];
          orderData['longitude'] = coordinates['longitude'];


          _orderAddress.add(orderData);
        } else {
          print('Coordinates could not be retrieved for address: ${orderData['address']}');
        }
      } else {
        print('Order not found or state is not equal to 1.');
      }

      notifyListeners();
    } catch (error) {
      print('Error loading order address: $error');
    }
  }






  Future<Map<String, dynamic>?> _getCoordinatesFromAddress(String address) async {
    final apiKey = 'AIzaSyAhdPlRZdpmTsE_pbzRn6SKPq8p-dmBRyM'; // Google Geocoding API anahtarını buraya ekleyin
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final results = decodedData['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        final geometry = results[0]['geometry'];
        final location = geometry['location'];
        final double latitude = location['lat'];
        final double longitude = location['lng'];
        return {'latitude': latitude, 'longitude': longitude};
      }
    }
    return null;
  }







  Future<void> deliverOrderToRider(String orderId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'state': (-1),
      });

    } catch (e) {
      print("Sipariş güncellenirken hata oluştu: $e");
    }
  }








}



