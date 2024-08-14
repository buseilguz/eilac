import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../viewModel/order_view_model.dart';
import 'courier_tracking_screen.dart';

class ActiveOrdersScreen extends StatefulWidget {
  @override
  _ActiveOrdersScreenState createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Bilinmiyor';
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Aktif Siparişler",style: TextStyle(color:Colors.yellow ),),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: orderViewModel.streamActiveOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aktif sipariş bulunamadı"));
          } else {
            var orders = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: orders.map((order) {
                    return Column(
                      children: [
                        Card(
                          elevation: 4.0,
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                "Sipariş Detayları",
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5.0),
                                  Text("$userName", style: TextStyle(color: Colors.redAccent)),
                                  SizedBox(height: 5.0),
                                  Text("Toplam Tutar: ₺${order['totalAmount']}", style: TextStyle(color: Colors.redAccent)),
                                  SizedBox(height: 5.0),
                                  Text("Adres: ${order['address']}", style: TextStyle(color: Colors.redAccent)),
                                  SizedBox(height: 5.0),
                                  Text("Tarih: ${order['timestamp'].toDate()}", style: TextStyle(color: Colors.redAccent)),
                                ],
                              ),
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (order['items'] as List<dynamic>).map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Text(
                                        "- ${item['name']}: ₺${item['price']}",
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: order['state'] == 1
                              ? Column(
                            children: [
                              Chip(
                                label: Text(
                                  "Kuryede",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.orange,
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _showCourierLiveTracking(context, order['riderId'], order['id']); // Siparişin doküman ID'sini de ekliyoruz
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.blue, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Kuryeyi Canlı Takip Et",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          )
                              : Chip(
                            label: Text("Aktif", style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showCourierLiveTracking(BuildContext context, String courierId, String orderId) { // Siparişin doküman ID'sini almak için bir parametre ekliyoruz
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourierTrackingScreen(courierId: courierId, orderId: orderId), // Siparişin doküman ID'sini gönderiyoruz
      ),
    );
  }
}

