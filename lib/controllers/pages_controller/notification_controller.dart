import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:mk_kabbani_admin/config.dart';

class NotificationController extends GetxController {

  String idType = "";
  String imageName = "";
  late DropzoneViewController? controller1;
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtContent = TextEditingController();
  TextEditingController txtProductCollectionId = TextEditingController();

  //send notification
  Future<void> sendNotification(
      {data}) async {
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);
    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
    }else {

      FirebaseFirestore.instance.collection(collectionName.users).get().then((value) {
        value.docs.asMap().entries.forEach((element)async {
          final data = {
            "notification": {"body": txtContent.text, "title": txtTitle.text,"icon" : "https://firebasestorage.googleapis.com/v0/b/mk-kabbnai-uae.appspot.com/o/logo.png?alt=media&token=f023d340-062a-4216-9e2e-eb6c18317870"},
            "priority": "high",
            "data": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "alertMessage": 'true',
              "title": txtTitle.text,
              "isProduct":idType == ""? "" : idType == "product" ? true : false,
              "productCollectionId": txtProductCollectionId.text,
            },
            "to": element.value.data()["pushToken"]
          };

          final headers = {
            'content-type': 'application/json',
            'Authorization':
            'key=AAAARZqu_10:APA91bFoj6V2ehXCQPd7EJf6u3fJUjjrjDELzWAXLUv5YDfheVWBj6FTIkQT5Q3IHJJLfu6_WkGRMjluIaUqSkpJKXKKDMXHnOAsni1yA4v189-evRNsO40DSJgI-Ir-oSrkD41gJBPj'
          };

          BaseOptions options = BaseOptions(
            connectTimeout: 5000,
            receiveTimeout: 3000,
            headers: headers,
          );

          try {
            final response = await Dio(options)
                .post('https://fcm.googleapis.com/fcm/send', data: data);

            if (response.statusCode == 200) {
              txtTitle.text = "";
              txtContent.text = "";
              txtProductCollectionId.text = "";
              idType = "";
              log('Alert push notification send');
            } else {
              log('notification sending failed');
              // on failure do sth
            }
          } catch (e) {
            log('exception $e');
          }
        });
      });
    }
  }
}
