import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {

  TextEditingController? textEditingController;
  IconData? iconData;
  String? hintString;
  bool? isObscure=true;
  bool? enabled=true;



  CustomTextField({super.key,this.textEditingController,this.iconData,this.enabled,this.hintString,this.isObscure});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12))        
      ),
      padding: const EdgeInsets.all(8),
      margin:const EdgeInsets.all(12),
      child: TextFormField(

        style: TextStyle(
          color: Colors.black
        ),
        enabled:widget.enabled ,
        controller: widget.textEditingController,
        obscureText: widget.isObscure!,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            widget.iconData,
            color: Colors.blueAccent,
          ),
          hintText: widget.hintString,
          hintStyle:const TextStyle(color: Colors.grey)
        ),

      ) ,
    );
  }
}
