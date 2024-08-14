import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewModel/order_view_model.dart';

class NewAvailableOrdersScreen extends StatefulWidget {
  @override
  _NewAvailableOrdersScreenState createState() => _NewAvailableOrdersScreenState();
}

class _NewAvailableOrdersScreenState extends State<NewAvailableOrdersScreen> {
  @override
  void initState() {
    super.initState();
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    orderViewModel.loadNearbyPharmaciesAndOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('En Yakın Eczane ve Siparişler'),
      ),
      body: OrderListView(),
    );
  }
}

class OrderListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);

    if (orderViewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (orderViewModel.nearbyPharmacies.isEmpty) {
      return Center(child: Text('Hata veya Veri Yok'));
    } else {
      return ListView.builder(
        itemCount: orderViewModel.nearbyPharmacies.length,
        itemBuilder: (context, index) {
          var pharmacy = orderViewModel.nearbyPharmacies[index];
          var orders = orderViewModel.nearbyOrders
              .where((order) => order['pharmacyId'] == pharmacy.id)
              .toList();
          if (orders.isEmpty) {
            return SizedBox.shrink(); // Boş bir widget döndür
          }


          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Mesafe: ${orderViewModel.calculateDistance(pharmacy)} km'),
                  Divider(),
                  Text('Siparişler:'),
                  ...orders.map((order) {
                    return ListTile(
                      title: Text('Order ID: ${order.id}'),
                      subtitle: Text("Kullanıcı ID :"+order['userId'].toString()+"---Sipariş tutarı-- :"+order['totalAmount'].toString()),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await orderViewModel.acceptOrder(order.id);
                        },
                        child: Text('Kabul Et'),
                      ),
                      // Diğer sipariş detaylarını buraya ekleyin
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
