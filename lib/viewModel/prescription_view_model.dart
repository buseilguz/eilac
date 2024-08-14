import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PrescriptionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = Uuid();

  Future<List> readPrescriptionFromFirestore(String tckn) async {
    List prescriptionsList = [];

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("prescriptions")
          .where("tckn", isEqualTo: tckn)
          .get();

      for (var document in querySnapshot.docs) {
        // Her reçete belgesi için ilac fiyatını al
        var medicineId = document["medicine_id"];
        var medicinePrice = await _getMedicinePrice(medicineId);

        prescriptionsList.add({
          "prescription_id":document.id,
          "name": document["name"],
          "description": document["description"],
          "tckn": document["tckn"],
          "medicine_id": medicineId,
          "price": medicinePrice,  // İlac fiyatını ekliyoruz
        });
      }
    } catch (e) {
      print("Error reading prescriptions: $e");
    }


    return prescriptionsList;
  }

  Future<double> _getMedicinePrice(String medicineId) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection("medicines")
          .doc(medicineId)
          .get();
      int price = documentSnapshot["price"];

      if (documentSnapshot.exists) {
        return price.toDouble();
      } else {
        print("Medicine not found: $medicineId");
        return 0.0;
      }
    } catch (e) {
      print("Error reading medicine price: $e");
      return 0.0;
    }
  }

  Future<void> deletePrescription(String prescriptionId) async {
    try {
      await _firestore.collection("prescriptions").doc(prescriptionId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting prescription: $e");
    }
  }
}




