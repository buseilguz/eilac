import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mainScreen/home_screen.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String titlemsg;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final Icon icon;

  const MyAppbar({
    Key? key,
    required this.showBackButton,
    required this.titlemsg,
    this.bottom,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      backgroundColor: Colors.black,
      leading: showBackButton
          ? IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
        },
      )
          : IconButton(
        icon: Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      centerTitle: true,
      title: Text(
        titlemsg,
        style: const TextStyle(
          fontSize: 20,
          letterSpacing: 3,
          color: Colors.white,
        ),
      ),
      actions: [
        Consumer(
          builder: (context, cart, child) {
            return Container(
              width: 25,
              child: const Stack(
               
              ),
            );
          },
        ),
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => bottom == null
      ? Size.fromHeight(AppBar().preferredSize.height)
      : Size.fromHeight(80 + AppBar().preferredSize.height);
}
