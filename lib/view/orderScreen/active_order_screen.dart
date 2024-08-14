import 'package:flutter/material.dart';
import 'package:pharmacy_app/view/lockBoxScreen/lock_box_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../viewModel/order_view_model.dart';


class ActiveOrdersScreen extends StatefulWidget {
  @override
  _ActiveOrdersScreenState createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  String? userName;
  List<String> selectedOrderIds = [];

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
        title: Text("Aktif Siparişler"),
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
                  children: [
                    ...orders.map((order) {
                      bool isOrderSelected = selectedOrderIds.contains(order['id']);
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
                                    Text("Hasta İsim: ${order['name']}", style: TextStyle(color: Colors.redAccent)),
                                    SizedBox(height: 5.0),
                                    Text("Toplam Tutar: ₺${order['totalAmount']}", style: TextStyle(color: Colors.redAccent)),
                                    SizedBox(height: 5.0),
                                    Text("Adres: ${order['address']}", style: TextStyle(color: Colors.redAccent)),
                                    SizedBox(height: 5.0),
                                    Text("Tarih: ${order['timestamp'].toDate()}", style: TextStyle(color: Colors.redAccent)),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10.0),
                                      child: ChoiceChip(
                                        label: Text(
                                          isOrderSelected ? "Kabul Edildi" : "Seç",
                                          style: TextStyle(color: isOrderSelected ? Colors.white : Colors.black),
                                        ),
                                        selected: isOrderSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedOrderIds.add(order['id']);
                                            } else {
                                              selectedOrderIds.remove(order['id']);
                                            }
                                          });
                                        },
                                        backgroundColor: isOrderSelected ? Colors.green : Colors.grey,
                                        selectedColor: Colors.green,
                                        labelStyle: TextStyle(
                                          color: isOrderSelected ? Colors.white : Colors.black,
                                        ),
                                        elevation: isOrderSelected ? 4 : 0,
                                        pressElevation: 2,
                                        avatar: isOrderSelected
                                            ? Icon(Icons.check, size: 18, color: Colors.white)
                                            : null,
                                        selectedShadowColor: Colors.black,
                                        shadowColor: Colors.grey,
                                      ),
                                    ),
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
                        ],
                      );
                    }).toList(),

                    // "Teslim Et" butonu
                    if (selectedOrderIds.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LockBoxScreen(selectedOrderIds: selectedOrderIds),),);
                        },
                        child: Text("Seçilen Siparişleri Teslim Et"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
