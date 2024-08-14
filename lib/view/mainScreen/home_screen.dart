import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:users_app/global/global_instances.dart';
import 'package:users_app/view/prescriptionScreens/prescription_screen.dart';
import 'package:users_app/view/widgets/my_appbar.dart';

import '../cardScreen/cart_screen.dart';
import '../widgets/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List bannerImagesList = [];
  List categoriesList = [];
  List pharmaciesList = [];
  String? selectedPharmacyId;
  String? selectedPharmacyName;

  updateUI() async {
    bannerImagesList = await homeViewModel.readBannersFromFirestore();
    categoriesList = await homeViewModel.readCategoriesFromFirestore();
    pharmaciesList = await homeViewModel.readPharmaciesFromFirestore();
    setState(() {
      bannerImagesList;
      categoriesList;
      pharmaciesList;
    });
  }

  @override
  void initState() {
    super.initState();
    updateUI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: MyAppbar(
        titlemsg: "eİlac",
        showBackButton: false,
        icon: Icon(Icons.card_travel),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white, // Arka plan rengini burada belirleyin
          child: Column(
            children: [
              //banners
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 10, right: 10),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * .3,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration: const Duration(milliseconds: 500),
                      autoPlayCurve: Curves.easeInOut,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: bannerImagesList.map((index) {
                      return Builder(builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Image.network(
                              index,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Eczane Seçiniz:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Eczaneler",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .4,
                child: SingleChildScrollView(
                  child: Column(
                    children: pharmaciesList.map((pharmacy) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Row(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Image.network(
                                  pharmacy["image"],
                                  width: 65, // Görüntü genişliğini ayarlayabilirsiniz
                                  height: 65, // Görüntü yüksekliğini ayarlayabilirsiniz
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10), // Görüntü ve metin arasına boşluk ekleyin
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pharmacy["name"],
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    pharmacy["address"],
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis, // Taşmayı önlemek için
                                    maxLines: 2, // Maksimum 2 satır
                                  ),
                                ],
                              ),
                            ],
                          ),
                          selected: selectedPharmacyId == pharmacy["id"],
                          onSelected: (c) {
                            setState(() {
                              selectedPharmacyId = pharmacy["id"];
                              selectedPharmacyName = pharmacy["name"];
                            });

                            commonViewModel.showSnackBar(pharmacy["name"], context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => PrescriptionScreen(
                                  pharmacyId: selectedPharmacyId,
                                  pharmacyName: selectedPharmacyName,
                                ),
                              ),
                            );
                          },
                          backgroundColor: Colors.white24,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
