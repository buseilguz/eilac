import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riders_app/global/global_vars.dart';
import 'package:riders_app/view/mainScreen/delivered_order_screen.dart';
import 'package:riders_app/view/mainScreen/earnings_screen.dart';
import 'package:riders_app/view/mainScreen/history_screen.dart';
import 'package:riders_app/view/mainScreen/new_available_orders_screen.dart';
import 'package:riders_app/view/mainScreen/accepted_orders_screen.dart';
import 'package:riders_app/view/mainScreen/parcels_in_progress_screen.dart';
import 'package:riders_app/view/mainScreen/past_orders_screen.dart';
import 'package:riders_app/view/splashScreen/splash_screen.dart';

import '../widgets/my_appbar.dart';
import '../widgets/my_drawer.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  Card dashboardItem(String title, IconData iconData, int index, BuildContext context) {

    return Card(

      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Container(
        height: 150, // Container'a belirli bir yükseklik ekleyin
        decoration: index == 0 || index == 3 || index == 4
            ? const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black87],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            tileMode: TileMode.clamp,
          ),
        )
            : const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            tileMode: TileMode.clamp,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (c) => NewAvailableOrdersScreen()));
            }
            if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (c) => DeliveredOrdersScreen()));
            }
            if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (c) => AcceptedOrdersScreen()));
            }
            if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (c) => PastOrdersScreen()));
            }
            if (index == 4) {
              Navigator.push(context, MaterialPageRoute(builder: (c) => EarningsScreen()));
            }
            if (index == 5) {
              FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c) => MySplashScreen()));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              const SizedBox(height: 50.0),
              Center(
                child: Icon(
                  iconData,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: MyAppbar(
        titlemsg: "eİlac",
        showBackButton: false,
        icon: Icon(Icons.card_travel),
      ),
      body: Container(

        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 1),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            dashboardItem("Yeni Siparişler", Icons.assignment, 0,context),
            dashboardItem("Sipariş Teslim", Icons.airport_shuttle, 1,context),
            dashboardItem("Mevcut Siparişler", Icons.location_history, 2,context),
            dashboardItem("Geçmiş Siparişler", Icons.done_all, 3,context),
            dashboardItem("Toplam Kazanç", Icons.monetization_on, 4,context),
            dashboardItem("Çıkış", Icons.logout, 5,context),
          ],
        ),
      ),
    );
  }
}

