import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderViewModel extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  List<DocumentSnapshot> _nearbyPharmacies = [];
  List<DocumentSnapshot> _nearbyOrders = [];
  List<Map<String, dynamic>> _acceptedOrders = [];
  List<Map<String, dynamic>> _deliveredOrders = [];
  List<Map<String, dynamic>> _pastOrders = [];

  bool _isLoading = false;

  List<DocumentSnapshot> get nearbyPharmacies => _nearbyPharmacies;
  List<DocumentSnapshot> get nearbyOrders => _nearbyOrders;
  List<Map<String, dynamic>> get acceptedOrders => _acceptedOrders;
  List<Map<String, dynamic>> get deliveredOrders => _deliveredOrders;
  List<Map<String, dynamic>> get pastOrders => _pastOrders;

  bool get isLoading => _isLoading;
  Position? get currentPosition => _currentPosition;

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadNearbyPharmaciesAndOrders() async {
    _isLoading = true;
    notifyListeners();
    await _startTrackingPosition();

    if (_currentPosition != null) {
      await _loadNearbyPharmacies();
      await _loadNearbyOrders();
    }

    _isLoading = false;
    notifyListeners();
  }



  Future<void> _startTrackingPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _currentPosition = position;
        _savePositionToDatabase(position);

        notifyListeners();
      });
    }
  }



  Future<void> _savePositionToDatabase(Position position) async {
    String? currentUserId=FirebaseAuth.instance.currentUser?.uid;
    try {
      await FirebaseFirestore.instance.collection('courier_locations').doc(currentUserId).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Konum veritabanına kaydedilirken hata oluştu: $e');
    }
  }



  Future<void> _loadNearbyPharmacies() async {
    _nearbyPharmacies.clear(); // Listeyi boşalt
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('pharmacies').get();
    List<DocumentSnapshot> allPharmacies = querySnapshot.docs;

    allPharmacies.forEach((pharmacy) {
      double latitude = pharmacy['latitude'];
      double longitude = pharmacy['longitude'];
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        latitude,
        longitude,
      );

      if (distance <= 5000) {
        _nearbyPharmacies.add(pharmacy);
      }
    });
  }

  Future<void> _loadNearbyOrders() async {
    _nearbyOrders.clear(); // Listeyi boşalt
    if (_nearbyPharmacies.isNotEmpty) {
      List<String> pharmacyIds = _nearbyPharmacies.take(30).map((pharmacy) => pharmacy.id).toList();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('pharmacyId', whereIn: pharmacyIds).where('accepted', isEqualTo: false).get();
      _nearbyOrders = querySnapshot.docs;
    }
  }

  Future<void> loadAcceptedOrders(String riderId) async {
    _acceptedOrders.clear();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('riderId', isEqualTo: riderId).where('state', isEqualTo: 0).get();

    for (var doc in querySnapshot.docs) {
      String userId = doc['userId'];
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;

        // Kullanıcı adını ve adresini sipariş verilerine ekle
        orderData['userName'] = userData['name'];
        orderData['address'] = orderData['address'];

        // Eczane konumunu siparişe ekle
        String pharmacyId = orderData['pharmacyId'];
        DocumentSnapshot pharmacySnapshot = await FirebaseFirestore.instance.collection('pharmacies').doc(pharmacyId).get();
        if (pharmacySnapshot.exists) {
          Map<String, dynamic> pharmacyData = pharmacySnapshot.data() as Map<String, dynamic>;
          orderData['pharmacyLocation'] = {
            'latitude': pharmacyData['latitude'],
            'longitude': pharmacyData['longitude']
          };
        }

        _acceptedOrders.add(orderData);
      }
    }

    notifyListeners();
  }

  Future<void> loadWillBeDeliveredOrders(String riderId) async {
    _deliveredOrders.clear();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('riderId', isEqualTo: riderId).where('state', isEqualTo: 1).get();

    for (var doc in querySnapshot.docs) {
      String userId = doc['userId'];
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;

        // Kullanıcı adını ve adresini sipariş verilerine ekle
        orderData['userName'] = userData['name'];
        orderData['address'] = orderData['address'];

        // Eczane konumunu siparişe ekle
        String pharmacyId = orderData['pharmacyId'];
        DocumentSnapshot pharmacySnapshot = await FirebaseFirestore.instance.collection('pharmacies').doc(pharmacyId).get();
        if (pharmacySnapshot.exists) {
          Map<String, dynamic> pharmacyData = pharmacySnapshot.data() as Map<String, dynamic>;
          orderData['userLocation'] = {
            'latitude': orderData['latitude'],
            'longitude': orderData['longitude']
          };
        }

        _deliveredOrders.add(orderData);
      }
    }

    notifyListeners();
  }

  String calculateDistance(DocumentSnapshot pharmacy) {
    double latitude = pharmacy['latitude'];
    double longitude = pharmacy['longitude'];
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    ) / 1000;
    return distance.toStringAsFixed(2);
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String riderId = currentUser.uid;

        await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'accepted': true,
          'riderId': riderId,
        });

        _nearbyOrders.removeWhere((order) => order.id == orderId);
        notifyListeners();
      } else {
        print("Aktif oturum açan kullanıcı bulunamadı.");
      }
    } catch (e) {
      print("Sipariş güncellenirken hata oluştu: $e");
    }
  }

  Future<void> receiveOrder(String orderId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'state': 1,
      });

    } catch (e) {
      print("Sipariş güncellenirken hata oluştu: $e");
    }
  }

  Future<void> loadPastOrders(String riderId) async {
    _pastOrders.clear();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('riderId', isEqualTo: riderId).where('state', isEqualTo: (-1)).get();

    for (var doc in querySnapshot.docs) {
      String userId = doc['userId'];
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;

        // Kullanıcı adını ve adresini sipariş verilerine ekle
        orderData['userName'] = userData['name'];
        orderData['address'] = orderData['address'];

        // Eczane konumunu siparişe ekle
        String pharmacyId = orderData['pharmacyId'];
        DocumentSnapshot pharmacySnapshot = await FirebaseFirestore.instance.collection('pharmacies').doc(pharmacyId).get();
        if (pharmacySnapshot.exists) {
          Map<String, dynamic> pharmacyData = pharmacySnapshot.data() as Map<String, dynamic>;
          orderData['pharmacyLocation'] = {
            'latitude': pharmacyData['latitude'],
            'longitude': pharmacyData['longitude']
          };
        }

        _pastOrders.add(orderData);
      }
    }

    notifyListeners();
  }



  Future<void> completeOrder(String orderId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {

        await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'completionDate': Timestamp.now(),
        });

        notifyListeners();
      } else {
        print("Aktif oturum açan kullanıcı bulunamadı.");
      }
    } catch (e) {
      print("Sipariş güncellenirken hata oluştu: $e");
    }
  }
}
