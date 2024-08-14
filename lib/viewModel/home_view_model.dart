import 'package:cloud_firestore/cloud_firestore.dart';

class HomeViewModel
{
  readBannersFromFirestore() async
  {
    List bannersList=[];
    await FirebaseFirestore.instance.collection("banners").get().then((QuerySnapshot querySnapshot)
    {
      querySnapshot.docs.forEach((document)
      {
        bannersList.add(document["image"]);
      });

    });


    return bannersList;
   }



  readCategoriesFromFirestore() async
  {
    List categoriesList=[];
    await FirebaseFirestore.instance.collection("categories").get().then((QuerySnapshot querySnapshot)
    {
      querySnapshot.docs.forEach((document)
      {
        categoriesList.add(document["name"]);
      });

    });


    return categoriesList;
  }



  Future<List<Map<String, dynamic>>> readPharmaciesFromFirestore() async {
    List<Map<String, dynamic>> pharmaciesList = [];
    await FirebaseFirestore.instance.collection("pharmacies").get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) {
        pharmaciesList.add({
          "id": document.id,
          "name": document["name"],
          "image": document["image"],
          "address": document["address"],
        });
      });
    });
    return pharmaciesList;
  }

}