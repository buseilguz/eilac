import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/global/global_instances.dart';

import '../../global/global_vars.dart';
import '../../viewModel/cart_view_model.dart';
import '../cardScreen/cart_screen.dart';
import '../widgets/my_appbar.dart';
import '../widgets/my_drawer.dart';

class PrescriptionScreen extends StatefulWidget {
  final String? pharmacyId;
  final String? pharmacyName;

  const PrescriptionScreen({super.key, this.pharmacyId, this.pharmacyName});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  List prescriptionList = [];

  updateUI() async {
    String? tckn = sharedPreferences?.getString("tckn");
    if (tckn == null) {
      // TCKN alınamıyorsa hata mesajı göster
      commonViewModel.showSnackBar("TCKN bulunamadı", context);
      return;
    }

    List prescriptions = await prescriptionViewModel.readPrescriptionFromFirestore(tckn);
    setState(() {
      prescriptionList = prescriptions;
    });
  }

  @override
  void initState() {
    super.initState();
    updateUI();
    Provider.of<CartViewModel>(context, listen: false).loadCartFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: MyAppbar(
        titlemsg: "eİlac",
        showBackButton: false,
        icon: Icon(Icons.card_travel),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20), // Üst tarafa boşluk eklemek için
            SizedBox(
              height: 90,
              child: prescriptionList.isEmpty
                  ? Center(child: Text('No prescriptions found'))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: prescriptionList.map((prescription) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ChoiceChip(
                        showCheckmark: true,
                        label: Row(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prescription["name"],
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    prescription["description"],
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    prescription["tckn"],
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    ("Fiyat:" + prescription["price"].toString()),
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        selected: cartViewModel.cartItems.contains(prescription),
                        onSelected: (selected) {
                          if (selected) {
                            cartViewModel.addToCart(prescription);
                          } else {
                            cartViewModel.removeFromCart(prescription);
                          }
                        },
                        backgroundColor: Colors.white24,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(
                      pharmacyId: widget.pharmacyId,
                      pharmacyName: widget.pharmacyName,
                    ),
                  ),
                );
              },
              child: Text('Sepete Git'),
            ),
          ],
        ),
      ),
    );
  }
}
