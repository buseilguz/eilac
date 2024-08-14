import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmacy_app/global/global_instances.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage ;
import 'package:pharmacy_app/global/global_vars.dart';
import 'package:pharmacy_app/view/mainScreen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel
{
  validateSignUpForm(XFile imageXFile,String password,String confirmPassword,String name,String email,String phone,String locationAddress,BuildContext context) async
  {
    if(imageXFile==null)
      {
        commonViewModel.showSnackBar("Lütfen bir resim seçiniz!", context);
        return;
      }
    else
      {
        if(password == confirmPassword)
          {
            if(name.isNotEmpty && email.isNotEmpty && password.isNotEmpty&&confirmPassword.isNotEmpty&&phone.isNotEmpty&&locationAddress.isNotEmpty)
              {
                commonViewModel.showSnackBar("Please wait...", context);
                //signup
              User? currentFirebaseUser=await createUserInFirebaseAuth(email,password,context);

               String downloadUrl=await uploadImageToStorage(imageXFile);

               await saveUserDataToFirestore(currentFirebaseUser,downloadUrl,name,email,password,locationAddress,phone);

               Navigator.push(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
               
               commonViewModel.showSnackBar("Account Created Successfully", context);
              }
            else
              {
                commonViewModel.showSnackBar("Lütfen bütün bilgileri giriniz!", context);
                return;

              }

          }
        else
          {
            commonViewModel.showSnackBar("Parola eşleşmesi başarısız!", context);
            return;

          }

      }
  }

  createUserInFirebaseAuth(String email,String password,BuildContext context) async
  {
    User? currentFirebaseUser;
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
    ).then((valueAuth)
    {
      currentFirebaseUser=valueAuth.user;
    }).catchError((errorMsg){
      commonViewModel.showSnackBar(errorMsg, context);
    });

    if(currentFirebaseUser==null)
      {
        FirebaseAuth.instance.signOut();

        return;
      }
    return currentFirebaseUser;

  }

  uploadImageToStorage(XFile? imageXFile) async
  {
    String downloadURL="";

    String fileName= DateTime.now().millisecondsSinceEpoch.toString();
    fStorage.Reference storageRef = fStorage.FirebaseStorage.instance.ref().child("pharmacyImages").child(fileName);
    fStorage.UploadTask uploadTask= storageRef.putFile(File(imageXFile!.path));
    fStorage.TaskSnapshot taskSnapshot= await uploadTask.whenComplete(()=>{});
    await taskSnapshot.ref.getDownloadURL().then((urlImage)
    {
     downloadURL=urlImage;
    });
    return downloadURL;
  }

  saveUserDataToFirestore(currentFirebaseUser,downloadUrl,name,email,password,locationAddress,phone)
  async {
    FirebaseFirestore.instance.collection("pharmacies").doc(currentFirebaseUser.uid).set(
        {
          "uid": currentFirebaseUser.uid,
          "email":email,
          "name":name,
          "image":downloadUrl,
          "phone":phone,
          "address":locationAddress,
          "status":"approved",
          "earnings":0.0,
          "latitude":position!.latitude,
          "longitude":position!.longitude

        });

      await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
      await sharedPreferences!.setString("email", email);
      await sharedPreferences!.setString("name", name);
      await sharedPreferences!.setString("imageUrl", downloadUrl);



  }

  validateSignInForm(String email,String password,BuildContext context) async{
    if(email.isNotEmpty && password.isNotEmpty)
      {
       commonViewModel.showSnackBar("Bİlgiler doğrulanıyor...", context);
       User? currentFirebaseUser=  await loginUser(email,password,context);

        await readDataFromFirestoreAndSetDataLocally(currentFirebaseUser,context);

        Navigator.push(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
      }
    else
      {
        commonViewModel.showSnackBar("Parola ve e-mail zorunlu alanlardır.", context);
        return;
      }
  }

  loginUser(email,password,context) async
  {
     User? currentFirebaseUser;
     
     await FirebaseAuth.instance.signInWithEmailAndPassword(
         email: email,
         password: password).then((valueAuth)
         {
          currentFirebaseUser= valueAuth.user;

         }).catchError((errorMsg)
     {
       commonViewModel.showSnackBar(errorMsg, context);
     });

     if(currentFirebaseUser==null)
       {
         FirebaseAuth.instance.signOut();
         return;
       }
     return currentFirebaseUser;

  }


  readDataFromFirestoreAndSetDataLocally(User? currentFirebaseUser,BuildContext context) async
  {
    await FirebaseFirestore.instance.collection("pharmacies").doc(currentFirebaseUser!.uid)
        .get()
        .then((dataSnapshot) async
    {
      if(dataSnapshot.exists)
        {
          if(dataSnapshot.data()!["status"]=="approved")
            {
              await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
              await sharedPreferences!.setString("email", dataSnapshot.data()!["email"]);
              await sharedPreferences!.setString("name",dataSnapshot.data()!["name"]);
              await sharedPreferences!.setString("imageUrl", dataSnapshot.data()!["image"]);

            }
          else
            {
              commonViewModel.showSnackBar("Admin tarafından giriş engellendi.", context);
            }
        }
      else
        {
          commonViewModel.showSnackBar("Geçerli eczane bulunamadı.", context);
          FirebaseAuth.instance.signOut();
          return;
        }
    });
  }
}