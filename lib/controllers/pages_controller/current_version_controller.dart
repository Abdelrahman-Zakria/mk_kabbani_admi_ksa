import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config.dart';

class CurrentVersionController extends GetxController{
  TextEditingController currentVersionTxt = TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    getData();

    super.onInit();
  }

  getData() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('currentVersion')
          .limit(1)
          .get();

      var data = snapshot.docs[0].data() as Map;


      currentVersionTxt.text = data['currentVersion'];


      update();
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  Future<void> updateFirestore(String newVersion, context) async {
    try {
      // Get the reference to the only document in the collection
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('currentVersion')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final String documentId = snapshot.docs.first.id;

        // Update Firestore document with the new data
        await FirebaseFirestore.instance
            .collection('currentVersion')
            .doc(documentId.trim())
            .update({
          'currentVersion': newVersion,
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Text(
              "Version has been updated successfully",
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