import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:users_app/global/global_instances.dart';

import '../../viewModel/order_view_model.dart';

class PassiveOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Geçmiş Siparişler"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: orderViewModel.streamPastOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Geçmiş sipariş bulunamadı"));
          } else {
            var orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      "Sipariş ID: ${order['id']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SizedBox(height: 8.0),
                        Text("Toplam Tutar: ₺${order['totalAmount']}"),
                        SizedBox(height: 4.0),
                        Text("Adres: ${order['address']}"),
                        SizedBox(height: 4.0),
                        Text("Tarih: ${order['timestamp'].toDate()}"),
                      ],
                    ),
                    onTap: () {
                      // Sipariş detaylarına gitmek için yapılacak işlemler
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
