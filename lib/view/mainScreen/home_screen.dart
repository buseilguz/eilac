import 'package:flutter/material.dart';
import 'package:pharmacy_app/view/orderScreen/past_order_screen.dart';
import 'package:provider/provider.dart';
import '../../global/global_vars.dart';
import '../../viewModel/order_view_model.dart';
import '../orderScreen/active_order_screen.dart';
import '../widgets/my_appbar.dart';
import '../widgets/my_drawer.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Açık gri arka plan rengi
      drawer: MyDrawer(),
      appBar: MyAppbar(
        titlemsg: "eİlac",
        showBackButton: false,
        icon: Icon(Icons.card_travel),
      ),
      body: SingleChildScrollView(
        child: Container(


          color: Colors.grey[200], // Arka plan rengini burada belirleyin
          child: Column(
            children: [
              const SizedBox(height: 18),

              Container(
                child: Column(
                  children: [

                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.10,
                      backgroundColor: Colors.white,
                      child:
                           Icon(
                        Icons.account_balance,
                        size: MediaQuery.of(context).size.width * 0.20,
                        color: Colors.red,
                      )

                    ),
                    Text(sharedPreferences!.getString("name").toString(),
                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),
                    ),


                  ],






                ),



              ),
              // Banners
              const SizedBox(height: 18),


              // Siparişleri Görüntüle Butonu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Consumer<OrderViewModel>(
                  builder: (context, orderViewModel, child) {
                    return Center(
                      child: Column(
                        children: [
                          StreamBuilder<int>(
                            stream: orderViewModel.streamActiveOrdersCount(),
                            builder: (context, snapshot) {
                              int orderCount = snapshot.data ?? 0;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.grey[800], // Buton metin rengi
                                  side: BorderSide(color: Colors.red, width: 2), // Kenar çizgisi (bordo)
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Kenar yuvarlaklığı
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => ActiveOrdersScreen()));
                                },
                                child: Stack(
                                  children: [
                                    Center(child: Text('Siparişleri Görüntüle',style: TextStyle(fontSize: 18),)),
                                    if (orderCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: 25,
                                            minHeight: 25,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$orderCount',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.grey[800], // Buton metin rengi
                              side: BorderSide(color: Colors.red, width: 2), // Kenar çizgisi (bordo)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Kenar yuvarlaklığı
                              ),
                              padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => PastOrdersScreen()));
                            },
                            child: Text('Geçmiş Siparişleri Görüntüle',style: TextStyle(fontSize: 18),),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
