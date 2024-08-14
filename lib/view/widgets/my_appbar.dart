import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/view/cardScreen/cart_screen.dart';
import 'package:users_app/viewModel/cart_view_model.dart';

import '../mainScreen/home_screen.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {

  String titlemsg;
  bool showBackButton;
  PreferredSizeWidget? bottom;
  Icon icon;
  int cartItemCount=CartViewModel().countItem();




   MyAppbar({super.key,required this.showBackButton,required this.titlemsg,this.bottom,required this.icon});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      backgroundColor: Colors.black,
      leading: showBackButton==true
          ? IconButton
        (
          icon:Icon(Icons.arrow_back,color: Colors.white,) ,
          onPressed: ()
        {
          Navigator.push(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
        },
         )
          :showBackButton==false
          ?IconButton(
            icon:Icon(Icons.menu,color: Colors.white,) ,
           onPressed: ()
          {
             Scaffold.of(context).openDrawer();
          },
           )
          : Container(),
      centerTitle: true,
      title: Text(
        titlemsg,
        style:const TextStyle(
          fontSize: 20,
          letterSpacing: 3,
          color: Colors.white
        ),

      ),
      actions: [
        Consumer<CartViewModel>(
          builder: (context,cart,child){
    return Stack(
    children: [
    IconButton(
    icon: icon,
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => CartScreen()));
      },
    ),
    //Sepetteki ürün sayısı etiketi
    if(cart.countItem()>0)
      Positioned(
    right: 0,
    child: CircleAvatar(
    backgroundColor: Colors.red,
    radius: 10,
    child: Text(
    cart.countItem().toString(),
    style: TextStyle(
    color: Colors.white,
    fontSize: 12,
    ),
    ),
    ),
    ),
    ],
    );},),
    ],

    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => bottom==null
      ?Size(57,AppBar().preferredSize.height)
      :Size(57,80+AppBar().preferredSize.height);


}
