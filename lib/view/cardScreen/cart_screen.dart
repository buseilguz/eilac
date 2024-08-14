import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewModel/cart_view_model.dart';
import '../../viewModel/order_view_model.dart';
import '../../viewModel/prescription_view_model.dart';
import '../widgets/my_appbar.dart';
import '../widgets/my_drawer.dart';

class CartScreen extends StatefulWidget {
  final String? pharmacyId;
  final String? pharmacyName;

  const CartScreen({super.key, this.pharmacyId, this.pharmacyName});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? selectedPaymentMethod;

  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('Kredi Kartı'),
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'Kredi Kartı';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Banka Kartı'),
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'Banka Kartı';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Nakit'),
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'Nakit';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(context);

    double totalAmount = cartViewModel.cartItems.fold(0, (sum, item) => sum + (item['price'] ?? 0.0));

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: MyAppbar(
        titlemsg: "Sepetim",
        showBackButton: true,
        icon: Icon(Icons.card_travel),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartViewModel.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartViewModel.cartItems[index];
                return ListTile(
                  title: Text(
                    item["name"],
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item["price"].toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () {
                      cartViewModel.removeFromCart(item);
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Toplam Tutar: \₺${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _showPaymentMethods(context);
                  },
                  child: Text('Ödeme Yöntemi Seç'),
                ),
                if (selectedPaymentMethod != null)
                  Text(
                    'Seçilen Ödeme Yöntemi: $selectedPaymentMethod',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedPaymentMethod == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Lütfen bir ödeme yöntemi seçin!'),
                      ));
                      return;
                    }

                    await orderViewModel.placeOrder(
                      cartViewModel.cartItems,
                      totalAmount,
                      pharmacyId: widget.pharmacyId,
                      pharmacyName: widget.pharmacyName,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Sipariş başarıyla verildi!'),
                    ));

                    for (var item in cartViewModel.cartItems) {
                      if (item.containsKey('prescription_id') && item['prescription_id'] != null) {
                        await prescriptionViewModel.deletePrescription(item['prescription_id']);
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Reçeteler başarıyla silindi!'),
                    ));

                    cartViewModel.clearCart();
                  },
                  child: Text('Sipariş Ver'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
