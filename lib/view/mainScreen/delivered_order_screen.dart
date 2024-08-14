import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riders_app/view/mainScreen/new_available_orders_screen.dart';
import '../../viewModel/order_view_model.dart';

class DeliveredOrdersScreen extends StatefulWidget {
  @override
  _DeliveredOrdersScreenState createState() => _DeliveredOrdersScreenState();
}

class _DeliveredOrdersScreenState extends State<DeliveredOrdersScreen> {
  GoogleMapController? mapController;
  late LatLng _initialPosition;
  late OrderViewModel orderViewModel;

  @override
  void initState() {
    super.initState();
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      orderViewModel.loadWillBeDeliveredOrders(currentUser.uid);
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
        title: Text('Sipariş Teslim'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Consumer<OrderViewModel>(
              builder: (context, orderViewModel, child) {
                if (orderViewModel.isLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (orderViewModel.deliveredOrders.isEmpty) {
                  return Center(child: Text('Teslim edilecek sipariş yok.'));
                } else {
                  return ListView.builder(
                    itemCount: orderViewModel.deliveredOrders.length,
                    itemBuilder: (context, index) {
                      var order = orderViewModel.deliveredOrders[index];
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
                              ],
                            ),
                            leading: Container(
                                width: 50,
                                child: Text('${order["pharmacyName"]}')),
                            trailing: Container(
                              width: 115,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await orderViewModel.completeOrder(order['id']);
                                  Navigator.push(context, MaterialPageRoute(builder: (c)=>NewAvailableOrdersScreen()));

                                },
                                style: ElevatedButton.styleFrom(
                                  maximumSize: Size(100, 135),
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text('Siparişi Tamamla', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Consumer<OrderViewModel>(
              builder: (context, orderViewModel, child) {
                if (orderViewModel.isLoading || orderViewModel.deliveredOrders.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  var order = orderViewModel.deliveredOrders.first;
                  var address = order['address'];
                  var currentPosition = orderViewModel.currentPosition ?? _initialPosition;

                  return FutureBuilder<LatLng>(
                    future: getLatLngFromAddress(address),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == LatLng(0, 0)) {
                        return Center(child: Text('Adres için konum bulunamadı.'));
                      } else {
                        LatLng userLocation = snapshot.data!;
                        return GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: userLocation,
                            zoom: 14.0,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('Hedef'),
                              position: userLocation,
                              infoWindow: InfoWindow(title: order['userName']),
                            ),
                            Marker(
                              markerId: const MarkerId('rider'),
                              position: LatLng(orderViewModel.currentPosition!.latitude, orderViewModel.currentPosition!.longitude),
                              infoWindow: InfoWindow(title: 'Şuanki Konum'),
                            ),
                          },
                          polylines: {
                            Polyline(
                              polylineId: PolylineId('route1'),
                              color: Colors.blue,
                              points: [
                                LatLng(orderViewModel.currentPosition!.latitude, orderViewModel.currentPosition!.longitude),
                                userLocation,
                              ],
                              width: 6,
                            ),
                          },
                        );
                      }
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
