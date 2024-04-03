import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mk_kabbani_admin/config.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/homeSectionsController.dart';

class DealsOfTheDayController extends GetxController {
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    getData();

    super.onInit();
  }

  getData() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dealsOfTheDayCollection')
          .limit(1)
          .get();

      HomeSectionsController homeSectionsController =
          Get.put(HomeSectionsController());

      await homeSectionsController.getData();

      var data = snapshot.docs[0].data() as Map;

      print("From deals of the day: $data");

      idController.text = data['id'];

      nameController.text = homeSectionsController.homeCategoryList
          .where((element) => element.id == data['id'])
          .toList()[0]
          .name!;

      update();
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  Future<void> updateFirestore(String newId, context) async {
    try {
      // Get the reference to the only document in the collection
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dealsOfTheDayCollection')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final String documentId = snapshot.docs.first.id;

        // Update Firestore document with the new data
        await FirebaseFirestore.instance
            .collection('dealsOfTheDayCollection')
            .doc(documentId)
            .update({
          'id': newId,
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Text(
              "Updated successfully",
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK".tr,
                    style: TextStyle(
                      color: appCtrl.appTheme.primary,
                    ),
                  ),
              ),
            ],
          ),
        );
        // Notify observers that the data has changed
        update();
      } else {
        print('No documents found in the collection.');
      }
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }
}
