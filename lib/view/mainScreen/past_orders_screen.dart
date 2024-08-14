import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../viewModel/order_view_model.dart';

class PastOrdersScreen extends StatefulWidget {
  @override
  _PastOrdersScreenState createState() => _PastOrdersScreenState();
}

class _PastOrdersScreenState extends State<PastOrdersScreen> {
  GoogleMapController? mapController;
  late LatLng _initialPosition;
  late OrderViewModel orderViewModel;

  @override
  void initState() {
    super.initState();
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      orderViewModel.loadPastOrders(currentUser.uid);
    }

    _initialPosition = LatLng(41.0082, 28.9784); // Istanbul için varsayılan konum

    // Konum güncellemelerini dinle
    orderViewModel.addListener(() {
      if (orderViewModel.currentPosition != null) {
        mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(
              orderViewModel.currentPosition!.latitude,
              orderViewModel.currentPosition!.longitude,
            ),
          ),
        );
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<LatLng> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print('Error: $e');
    }
    return LatLng(0, 0); // Default value if address not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geçmiş Siparişler'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Consumer<OrderViewModel>(
              builder: (context, orderViewModel, child) {
                if (orderViewModel.isLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (orderViewModel.pastOrders.isEmpty) {
                  return Center(child: Text('Geçmiş sipariş bulunamadı.'));
                } else {
                  return ListView.builder(
                    itemCount: orderViewModel.pastOrders.length,
                    itemBuilder: (context, index) {
                      var order = orderViewModel.pastOrders[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text('Sipariş ID: ${order['id']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sipariş tutarı: ${order['totalAmount']}'),
                                Text('Kullanıcı adı: ${order['userName']}'),
                                Text('Adresi: ${order['address']}'),
                                Text('Teslim Tarihi: ${(order['completionDate'] as Timestamp).toDate()}'),

                              ],
                            ),
                            leading: Container(
                                width: 50,
                                child: Text('${order["pharmacyName"]}')),

                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),

        ],
      ),
    );
  }
}
