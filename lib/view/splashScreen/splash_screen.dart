
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../authScreens/auth_screen.dart';
import '../mainScreen/home_screen.dart';
class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

  initTimer()
  {
    Timer(const Duration(seconds: 3),() async
  {
    if(FirebaseAuth.instance.currentUser== null)
    {
      Navigator.push(context, MaterialPageRoute(builder: (c)=>AuthScreen()));

    }
    else
    {
      Navigator.push(context, MaterialPageRoute(builder: (c)=>HomeScreen()));

    }
  });


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTimer();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Image.asset(
                 "images/logo.png"
               ),
             ),
            Text(
              "E-ilaç Uygulaması",
              textAlign: TextAlign.center ,
              style: TextStyle(
                letterSpacing: 3,
                fontSize: 26,
                color: Colors.grey
              ),
            ),
          ],
        ),
      ),
    );
  }
}
