import 'package:flutter/material.dart';
import '../../global/global_instances.dart';
import '../widgets/custom_text_field.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {

  TextEditingController emailTextEditingController=TextEditingController();
  TextEditingController passwordTextEditingController=TextEditingController();
  TextEditingController tcknTextEditingController=TextEditingController();


  GlobalKey<FormState> formKey=GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [

          Container(
            alignment: Alignment.bottomCenter ,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "images/logo.png",
                height: 270,
              ),
            ),
          ),
          Form(
              key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  textEditingController:tcknTextEditingController,
                  iconData: Icons.email,
                  hintString: "Tc Kimlik Numaranızı Giriniz",
                  isObscure: false,
                  enabled: true,
                ),
                CustomTextField(
                  textEditingController:emailTextEditingController,
                  iconData: Icons.email,
                  hintString: "Email Giriniz",
                  isObscure: false,
                  enabled: true,
                ),
                CustomTextField(
                  textEditingController:passwordTextEditingController,
                  iconData: Icons.lock,
                  hintString: "Parola Giriniz",
                  isObscure: true,
                  enabled: true,
                ),
                ElevatedButton(
                    onPressed: ()
                    {
                      authViewModel.validateSignInForm(
                        emailTextEditingController.text.trim(),
                        passwordTextEditingController.text.trim(),
                        context,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
                    ),
                  child: const Text(
                    "Giriş Yap",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),

                )


              ],
            ),
          ),
        ],
      ),
    );
  }
}
