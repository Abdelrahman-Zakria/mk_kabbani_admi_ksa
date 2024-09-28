import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../models/warranty_activation.dart';

class WarrantyActivationController extends GetxController{
  List<WarrantyActivation> warranties = [];
  List<WarrantyActivation> filteredWarranties = [];

  getWarrantiesList()async{
   await FirebaseFirestore.instance.collection("warrantyActivation").get().then((value){
     value.docs.asMap().entries.forEach((element){
       warranties.add(WarrantyActivation(
         firstName: element.value.data()["firstName"],
         lastName: element.value.data()["lastName"],
         emirate: element.value.data()["emirate"],
         date: element.value.data()["date"],
         phone: element.value.data()["phone"],
         invoiceNumber: element.value.data()["invoiceNumber"],
         status: element.value.data()["status"],
       ));
       update();
     });
   });
   filteredWarranties = warranties;
   print("Warranties list length: ${warranties.length}");
  }

  Future<void> activateWarrantyByInvoiceNumber(String invoiceNumber) async {
    try {
      // Query the collection for the document with the given invoice number
      final querySnapshot = await FirebaseFirestore.instance
          .collection("warrantyActivation")
          .where("invoiceNumber", isEqualTo: invoiceNumber)
          .get();

      // Check if we found any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Assuming invoice numbers are unique, we update the first (and likely only) document found
        final docId = querySnapshot.docs.first.id;

        // Update the status field of the document to "active"
        await FirebaseFirestore.instance
            .collection("warrantyActivation")
            .doc(docId)
            .update({"status": "active"});

        // Optionally, log or notify that the status update was successful
        print("Status updated to 'active' for invoice number: $invoiceNumber");
warranties.clear();
update();
        getWarrantiesList();
        update();
      } else {
        // Handle the case where no document matches the invoice number
        print("No document found with invoice number: $invoiceNumber");
      }
    } catch (e) {
      // Print or handle any errors that occur
      print("An error occurred while updating status: $e");
    }
  }

  void filterWarrantiesByInvoiceNumber(String query) {
    if (query.isEmpty) {
      filteredWarranties = warranties;
    } else {
      filteredWarranties = warranties.where((warranty) {
        return warranty.invoiceNumber!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    update(); // Update the UI
  }

  @override
  void onInit() {
    super.onInit();
    getWarrantiesList();
  }

}