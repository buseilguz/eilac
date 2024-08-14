import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riders_app/view/mainScreen/delivered_order_screen.dart';
import '../../viewModel/order_view_model.dart';

class AcceptedOrdersScreen extends StatefulWidget {
  @override
  _AcceptedOrdersScreenState createState() => _AcceptedOrdersScreenState();
}

class _AcceptedOrdersScreenState extends State<AcceptedOrdersScreen> {
  GoogleMapController? mapController;
  late LatLng _initialPosition;
  late OrderViewModel orderViewModel;

  @override
  void initState() {
    super.initState();
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      orderViewModel.loadAcceptedOrders(currentUser.uid);
    }

    _initialPosition = LatLng(41.0082, 28.9784); // Istanbul için varsayılan konum
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kabul Edilen Siparişler'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Consumer<OrderViewModel>(
              builder: (context, orderViewModel, child) {
                if (orderViewModel.isLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (orderViewModel.acceptedOrders.isEmpty) {
                  return Center(child: Text('Kabul edilen sipariş yok.'));
                } else {
                  return ListView.builder(
                    itemCount: orderViewModel.acceptedOrders.length,
                    itemBuilder: (context, index) {
                      var order = orderViewModel.acceptedOrders[index];
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
                              width: 90,
                              child: ElevatedButton(
                                onPressed: () async {
                                  var orderId = order['id']; // Siparişin id'sini alın
                                  await orderViewModel.receiveOrder(orderId);

                                  Navigator.push(context, MaterialPageRoute(builder: (c)=>DeliveredOrdersScreen()));
// receiveOrder metodunu çağırın
                                },
                                style: ElevatedButton.styleFrom(
                                  maximumSize:Size(100, 135) ,
                                  backgroundColor: Colors.blue, // Arka plan rengini buradan değiştirin
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // Dikdörtgen şekli buradan ayarlayın
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10), // Yukarı taşınacak boşluk buradan ayarlanabilir
                                  child: Text('Teslim Aldım',style: TextStyle(color: Colors.white,fontSize: 12),),
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
                if (orderViewModel.isLoading || orderViewModel.acceptedOrders.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  var order = orderViewModel.acceptedOrders.first;
                  var pharmacyLocation = order['pharmacyLocation'];
                  var currentPosition = orderViewModel.currentPosition ?? _initialPosition;

                  return GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(pharmacyLocation['latitude'], pharmacyLocation['longitude']),
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('pharmacy'),
                        position: LatLng(pharmacyLocation['latitude'], pharmacyLocation['longitude']),
                        infoWindow: InfoWindow(title: order['pharmacyName']),
                      ),
                      Marker(
                        markerId: MarkerId('rider'),
                        position: LatLng(orderViewModel.currentPosition!.latitude, orderViewModel.currentPosition!.longitude),
                        infoWindow: InfoWindow(title: 'Şuanki Konum'),
                      ),
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
