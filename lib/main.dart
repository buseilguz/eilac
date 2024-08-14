import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_app/view/splashScreen/splash_screen.dart';
import 'package:users_app/viewModel/cart_view_model.dart';
import 'package:users_app/viewModel/order_view_model.dart';
import 'package:users_app/viewModel/prescription_view_model.dart';

import 'global/global_vars.dart';

Future <void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  sharedPreferences=await SharedPreferences.getInstance();

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission)
{
      if(valueOfPermission)
  {
    Permission.locationWhenInUse.request();
}

});


  runApp( MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PrescriptionViewModel()),
      ChangeNotifierProvider(create: (_) => CartViewModel()),
      ChangeNotifierProvider(create: (_) => OrderViewModel()),


    ],
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      home: MySplashScreen(),
    );
  }
}
