import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_app/global/global_instances.dart';
import 'package:pharmacy_app/global/global_vars.dart';
import 'package:pharmacy_app/view/mainScreen/home_screen.dart';
import 'package:pharmacy_app/view/orderScreen/active_order_screen.dart';
import 'package:pharmacy_app/view/orderScreen/past_order_screen.dart';
import 'package:pharmacy_app/view/splashScreen/splash_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          //header
          Container(
            padding: const EdgeInsets.only(top: 25,bottom: 10),
            child: Column(
              children: [
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(81)),
                  elevation: 8,
                  child: SizedBox(
                    height: 158,
                    width: 158,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        sharedPreferences!.getString("imageUrl").toString(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12,),

                Text(
                  sharedPreferences!.getString("name").toString(),
                  style:const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,

                  ),

                ),
              ],
            ),
          ),

          const SizedBox(height: 12,),

          //body
          Container(
            child: Column(
              children: [
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,

                ),
                ListTile(
                  leading:const Icon(Icons.home,color: Colors.white,),
                  title: const Text(
                    "Anasayfa",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
                  },
                ),

                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,

                ),
                ListTile(
                  leading:const Icon(Icons.monetization_on,color: Colors.white,),
                  title: const Text(
                    "Bakiye",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
                  },
                ),

                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,

                ),
                ListTile(
                  leading:const Icon(Icons.reorder,color: Colors.white,),
                  title: const Text(
                    "Yeni Sipariş",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>ActiveOrdersScreen()));
                  },
                ),


                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,

                ),
                ListTile(
                  leading:const Icon(Icons.local_shipping,color: Colors.white,),
                  title: const Text(
                    "Geçmiş Siparişler",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>PastOrdersScreen()));
                  },
                ),


                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,

                ),
                ListTile(
                  leading:const Icon(Icons.share_location,color: Colors.white,),
                  title: const Text(
                    "Adresi Güncelle",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: ()
                  {
                    commonViewModel.updateLocationInDatabase();
                    commonViewModel.showSnackBar("Adresiniz başarıyla güncellendi", context);

                  },
                ),


                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,

                ),
                ListTile(
                  leading:const Icon(Icons.exit_to_app,color: Colors.white,),
                  title: const Text(
                    "Çıkış Yap",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: ()
                  {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>MySplashScreen()));
                  },
                ),

                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,

                ),


              ],
            ),
          ),

        ],
      ),
    );
  }
}


