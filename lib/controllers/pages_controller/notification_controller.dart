import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:mk_kabbani_admin/config.dart';
import 'package:mk_kabbani_admin/models/category_model.dart' as cat;
import 'package:mk_kabbani_admin/models/product_model.dart' as product_model;
import '../../shopify/shopify_mixin.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:http/http.dart' as http;


class NotificationController extends GetxController with ShopifyMixin {
  String idType = "";
  String imageName = "";
  late DropzoneViewController? controller1;
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtContent = TextEditingController();
  TextEditingController txtProductCollectionId = TextEditingController();
  List<cat.Category> homeCategoryList = [];
  List<product_model.Product> productList = [];
  String? selectedProductCollectionId;

  @override
  onInit() {
    super.onInit();
    getData();
  }

  getAccessToken()async{
    final serviceJson = {
      "type": "service_account",
      "project_id": "mk-kabbnai-uae",
      "private_key_id": "c0b24b7b154af32f348d419515e8d5e168cdcbf9",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDt5D05+NHuGJO0\nL2KaKrkk+T3D3IMNvepIDJWkvFfst24Fq8G/bHXpG30f14kqT2J/L9+oX0eEJwoI\nf6IzR/gDLxZIlHtrS62dU62GVnBOlZkEiqxNoZZ6yIz0cMrT3KSWenyybj3I6Tuv\nVPmaOkqCg2CoD0us8PBiKxIDH9lsWt/6tu1p04py4qqYENNlkOKGp/3PQiROOZPa\nUTRWV0q1g34nK78mlMZOnmF0uTeA2ioRIO1JUn10HdWDbsiQOcR6POSxTmnNW50c\n5BBkCSdNGHIYn2Q/mD3nKGL7w+CDaZ4j9lwSDjkoDBh5vKaGXYjnKPz0hV+Nld3I\nzkNJ0B2bAgMBAAECggEABl+bjlPkF/YbmvO8DLer+dly9gOQlUvVx4lixvpEJsjr\n+dtArRwUSqMHEVUpInOPBtZQWTFNorTtuA2SBGq0soJ5R9zb3k41lWX6W64xgxbP\nSzJbQcHcXLzGc1QZnbR8dQr3ZUu+fFqsqTAPIeUsPYk/NobLtxNGIB3Zn9t4wUY0\nHxlWrJgAUTBGdCHHjs9YloMPDeEzKqnl7nSQYqlXMZuslPHtFB2ebRoarMro8B6i\n7spWrZKVG7AV1RdZd/6frWXsIRKrLrwdAnNffaHy/0TdWZ2J/0JTBlzxcBJK9Bbl\nNLdnLiI1pYrysmDpcIPnU2KrNd+eKSEnxSC8uhnilQKBgQD4MSCwXoFQxpnxpzLK\nr7RIEIxMtcIUoKEisrPrb1h9aeumwqHBQ4KmgU/YIO4RwRxpJPS44r5tbBn2SZHS\nOkuxmNnNWe6oC569Y+rn2/prvfqfeYIuYiGsiovzxtBHCodx/oxyfX1OrtAKxc0e\nJ+XXIFGz8oOFHbrx9mTLTnvOTQKBgQD1YCe7JYPoSgBoyfQSGfedkXLSYA33WXWn\nqBbCWEwfBgRvOctUtGLXsjU5Xwg0NAFyFHJc/pwH7KALeY0UXmvl7Bz1IK4WQwTd\nBBPGevf4DvRTSu5RxD3VqnkIu1hkXqMk1wGVYCrKe3sNfDM11SvgoixSL+Lj4Lsg\nj2RD7jcfhwKBgQCVHXclX/JT5K6zOKBUlJI9Rev1XrKXkBaf8TwV9NT2rL/PdlqW\n8ge6IDEnikle02ZNac26k0iUF4HVrkf1Rd8aedpJ/YFc53ZdFX4aBdmECCVe0TM8\nyOqwbqE9OrMCK7pK7APX+btinbcS8dqWBqSZxqov8kHApacfHslaOPI7dQKBgQDV\nfqpTHRseO3ULt9vS/CEESg87mDPOqVnDXG8g/a6Nt7CYDhMqSiFOR1Ij7tm2giFX\n3w56d1XPV0URdtsXg+ghj0TKy3ptCDbtDqUeJtQmUuympCWjozmh9MeGn2sTOXx9\ni01naNsSfkncu9na1vVsZ+5kPCIP3/MxK1I0AMqZdQKBgQClBXRjZ1oiybu8ZAdf\nUHH7btybURAdW/tq6vVG3zgEFXDlhyQmkeKtrFYYKiOGJezv6uv6wMeV88zm1eAN\nRjdCmo2Ke7/8W/6KoUwVOCGXtq2K82tvfvVZ+dgA2gpfPScBg9P4JN/FMWjOgt0B\nAEOu18Xdte1O+toZ3YHisLnInA==\n-----END PRIVATE KEY-----\n",
      "client_email": "mk-kabbani-uae@mk-kabbnai-uae.iam.gserviceaccount.com",
      "client_id": "104830490588083400717",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/mk-kabbani-uae%40mk-kabbnai-uae.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(
          serviceJson
      ),
      scopes,
    );

    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(
          serviceJson
      ),
      scopes,
      client,
    );
    client.close();
    return credentials.accessToken.data;
  }


  sendPushNotification()async{

    final String serverKey = await getAccessToken();
    String endPoint = 'https://fcm.googleapis.com/v1/projects/mk-kabbnai-uae/messages:send';

    try {
      print("Title: ${txtTitle.text} , Content: ${txtContent.text}");
      final data = {
        "message": {
          "topic": "all",
          "notification": {
            "title": "${txtTitle.text}",
            "body": "${txtContent.text}",
          },
        }
      };


      final http.Response res =  await http.post(
        Uri.parse(endPoint),
        headers: {
          'Content-Type' : 'application/json',
          'Authorization' : 'Bearer $serverKey'
        },
        body: jsonEncode(data),
      );

      if(res.statusCode == 200){
        print("Notification sent successfully");
      }else{

        print("Notification failed: ${res.statusCode}");

      }
      if (res.statusCode == 200) {
        txtTitle.text = "";
        txtContent.text = "";
        txtProductCollectionId.text = "";
        idType = "";
        update();
        log('Alert push notification send');
      } else {
        log('notification sending failed: ${res.statusCode}');
      }
    } catch (e) {
      log('exception $e');
    }


  }


  Future<void> sendNotification({data}) async {
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);
    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
    } else {
      FirebaseFirestore.instance.collection(collectionName.users).get().then((value) {
        value.docs.asMap().entries.forEach((element) async {
          final data = {
            "notification": {
              "body": txtContent.text,
              "title": txtTitle.text,
              "icon": "https://firebasestorage.googleapis.com/v0/b/mk-kabbnai-uae.appspot.com/o/logo.png?alt=media&token=f023d340-062a-4216-9e2e-eb6c18317870"
            },
            "priority": "high",
            "data": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "alertMessage": 'true',
              "title": txtTitle.text,
              "isProduct": idType == "" ? "" : idType == "product" ? true : false,
              "productCollectionId": selectedProductCollectionId,
            },
            "to": element.value.data()["pushToken"]
          };

          final headers = {
            'content-type': 'application/json',
            'Authorization': 'key=AAAARZqu_10:APA91bFoj6V2ehXCQPd7EJf6u3fJUjjrjDELzWAXLUv5YDfheVWBj6FTIkQT5Q3IHJJLfu6_WkGRMjluIaUqSkpJKXKKDMXHnOAsni1yA4v189-evRNsO40DSJgI-Ir-oSrkD41gJBPj'
          };

          BaseOptions options = BaseOptions(
            connectTimeout: Duration(seconds: 5000),
            receiveTimeout: Duration(seconds: 3000),
            headers: headers,
          );

          try {
            final response = await Dio(options).post('https://fcm.googleapis.com/fcm/send', data: data);

            if (response.statusCode == 200) {
              txtTitle.text = "";
              txtContent.text = "";
              txtProductCollectionId.text = "";
              idType = "";
              log('Alert push notification send');
            } else {
              log('notification sending failed');
            }
          } catch (e) {
            log('exception $e');
          }
        });
      });
    }
  }

  getData() async {
    log("Get data started");
    homeCategoryList = await shopifyService.getCategoriesByCursor();
    for (cat.Category category in homeCategoryList) {
      print("Title ${category.name} , id: ${category.id} , banner: ${category.image ?? ""}");
    }

    productList = await shopifyService.getAllProduct();

    for (product_model.Product product in productList) {
      print("Product Title ${product.name} , id: ${product.id} , banner: ${product.images[0] ?? ""}");
    }

    productList.sort((a, b) => a.name!.compareTo(b.name!));
    update();
  }
}
