import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mk_kabbani_admin/pages/home_category_list/layouts/add_banner_home_cat_list.dart';
import 'package:mk_kabbani_admin/pages/home_category_list/layouts/update_banner_home_cat_list.dart';
import 'package:mk_kabbani_admin/pages/index/index.dart';
import 'package:mk_kabbani_admin/shopify/shopify_mixin.dart';
import 'package:mk_kabbani_admin/models/category_model.dart' as cat;
import 'dart:io' as io;

import 'package:mk_kabbani_admin/widgets/helper_function.dart';

import '../../config.dart';



class HomeCatListController extends GetxController with ShopifyMixin{


  List<cat.Category> homeCategoryList = [];

  List<cat.Category> homeCategoryView = [];

  bool isLoading = true;


  bool isSearch = false, isUploadSize = false, isAlert = false;


  List firebaseCats = [];

  String imageName = "", imageUrl = "";
  String imageNameAr = "", imageUrlAr = "";

  Uint8List webImage = Uint8List(8);
  Uint8List webImageAr = Uint8List(8);

  io.File? pickImage;
  io.File? pickImageAr;

  Uint8List uploadWebImage = Uint8List(8);
  Uint8List uploadWebImageAr = Uint8List(8);

  XFile? imageFile;
  XFile? imageFileAr;

  String idType = "", bannerId = "";


  bool? isShown;
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtTitleAr = TextEditingController();

  TextEditingController txtId = TextEditingController();
  TextEditingController addNewId = TextEditingController();
  TextEditingController addNewTitle = TextEditingController();
  TextEditingController addNewBanner = TextEditingController();

  late DropzoneViewController? controller1;
  late DropzoneViewController? controller2;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  getData()async{
    homeCategoryList = await shopifyService.getCategoriesByCursor();

    var collections =  await FirebaseFirestore.instance
        .collection('homeCategorySlider')
        .get();

    // updatePriorities();



    List<DocumentSnapshot> documentSnapshot = collections.docs;
    DocumentSnapshot catDoc = documentSnapshot[0];

    Map catDocData = catDoc.data() as Map;

    List cats = catDocData['mainCategoryAr'];

    homeCategoryView.clear();

    firebaseCats = cats;

    List catsId = cats.map((e) => e['id']).toList();

    print("CATS IDS $catsId");

    for(int i = 0 ; i < homeCategoryList.length ; i++ ){
      print("IS FOUND: ${catsId.contains(homeCategoryList[i].id!.trim())} ID: ${homeCategoryList[i].id!.trim()}");
      if(homeCategoryList[i].id!.trim() == "gid://shopify/Collection/267215405224"){
        print("gid://shopify/Collection/267215405224 Found");
        print("FROM FIRE CATS gid://shopify/Collection/267215405224: ${catsId.contains(homeCategoryList[i].id!.trim())}");
      }
      if(catsId.contains(homeCategoryList[i].id!.trim())) {
        if(!homeCategoryView.contains(homeCategoryList[i])){

          bool isFound = homeCategoryView.firstWhereOrNull((element) => element.id == homeCategoryList[i].id) != null;

          if(isFound){
            print("FOUND NOT ADDING");
          }else{
            homeCategoryView.add(homeCategoryList[i]);
            if(homeCategoryList[i].id!.trim() == "gid://shopify/Collection/267215405224"){
              print("Tik Tik Mawgood");
            }
            print("NOT FOUND ADDING ${homeCategoryList[i].id}");
            update();

          }
        }
        update();
      }
    }

    print("Home CAT VIEW" + homeCategoryView.length.toString());

    firebaseCats.forEach((element) {
      print("FROM FIREBASE LIST: $element");
    });

    catsId.forEach((cat) {
      print("ID: $cat CAT FOUND: ${homeCategoryView.contains(homeCategoryList.firstWhere((item) => item.id == cat))}");
      print(homeCategoryView.length);
      if(! homeCategoryView.contains(homeCategoryList.firstWhere((item) => item.id == cat))){
        homeCategoryView.add(homeCategoryList.firstWhere((element) => element.id == cat));

        print("Added if not found");


      }
    });

    homeCategoryView.sort((a, b) =>
        firebaseCats
            .firstWhere((element) => element['id'] == a.id)['priority']
            .compareTo(
            firebaseCats
                .firstWhere((element) => element['id'] == b.id)['priority']));

    //homeCategoryView = homeCategoryView.toSet().toList();



    print("Home CAt list length: ${homeCategoryView.length}");


    update();

    isLoading = false;

    update();
  }

  void updatePrioritiesInFirestore(BuildContext context, int oldIndex, int newIndex) async {
    String categoryId1 = homeCategoryView[oldIndex].id!;
    String categoryId2 = homeCategoryView[newIndex].id!;

    int oldPriority1 = firebaseCats.firstWhere((element) => element['id'] == categoryId1)['priority'];
    int oldPriority2 = firebaseCats.firstWhere((element) => element['id'] == categoryId2)['priority'];

    // Swap priorities
    int newPriority1 = oldPriority2;
    int newPriority2 = oldPriority1;



    // Update category 1 in Firestore
    await updateFirestoreMainCategoryArPriority(categoryId1,categoryId1, newPriority1);

    // Update category 2 in Firestore
    await updateFirestoreMainCategoryArPriority(categoryId2,categoryId2, newPriority2);

    // Update the priority in the local list for category 1
    firebaseCats
        .firstWhere((element) => element['id'] == categoryId1)['priority'] =
        newPriority1;

    // Update the priority in the local list for category 2
    firebaseCats
        .firstWhere((element) => element['id'] == categoryId2)['priority'] =
        newPriority2;

    // Sort the switchValues based on the updated priorities
    firebaseCats.sort((a, b) =>
        a['priority'].compareTo(b['priority']));

    // Sort the homeCategoryList based on the sorted switchValues
    homeCategoryView.sort((a, b) =>
        firebaseCats
            .firstWhere((element) => element['id'] == a.id)['priority']
            .compareTo(
            firebaseCats
                .firstWhere((element) => element['id'] == b.id)['priority']));

    isLoading = false;

    // Trigger a rebuild of the UI
    update();

    // Delay to show CircularProgressIndicator for a short duration

    // Pop the dialog
  }


  Future<void> updateFirestoreMainCategoryArPriority(String categoryId, String itemId, int newPriority) async {
    print("Updating Firestore for categoryId: $categoryId, itemId: $itemId, newPriority: $newPriority");

    try {
      // Retrieve the document
      DocumentReference<Map<String, dynamic>> documentReference =
      FirebaseFirestore.instance.collection("homeCategorySlider").doc('QhYlLUCSusla8bZheQ5g');

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        // Get the existing data
        Map<String, dynamic> existingData = documentSnapshot.data()!;

        // Find the index of the item in the 'mainCategoryAr' list
        int index = existingData['mainCategoryAr'].indexWhere((item) => item['id'] == itemId);

        // If the item with 'id' is found, update its 'priority'
        if (index != -1) {
          existingData['mainCategoryAr'][index]['priority'] = newPriority;
        } else {
          print("Item with itemId: $itemId not found in mainCategoryAr list");
          return;
        }

        // Update the document with the modified data
        await documentReference.update(existingData);

        firebaseCats = existingData['mainCategoryAr'];



        print("Firestore update successful for categoryId: $categoryId");
      } else {
        print("Document not found for categoryId: $categoryId");
      }
    } catch (error) {
      print("Error updating Firestore for categoryId: $categoryId, Error: $error");
    }
  }

  changeNewSectionId(newId){
    addNewId.text = newId;
    addNewTitle.text = homeCategoryView.where((element) => element.id == newId).toList()[0].name!;
    addNewBanner.text = homeCategoryView.where((element) => element.id == newId).toList()[0].image!;
    update();
  }

  Future getImage({source, StateSetter? setState, dropImage, context}) async {
    if (dropImage != null) {
      if (imageName.contains("png") ||
          imageName.contains("jpg") ||
          imageName.contains("jpeg")) {
        var image = dropImage;
        uploadWebImage = image;
        Image image1 = Image.memory(uploadWebImage);

        ImageInfo info = await getImageInfo(image1);

        if (info.image.width > 300 && info.image.height > 50) {
          webImage = uploadWebImage;
          pickImage = io.File("a");
          isUploadSize = false;
        } else {
          isUploadSize = true;
        }

        isAlert = false;
        update();
      } else {
        isAlert = true;
        update();
        await Future.delayed(Durationss.s2);
        isAlert = false;
        update();
      }
    } else {
      final ImagePicker picker = ImagePicker();
      imageFile = (await picker.pickImage(source: ImageSource.gallery))!;

      if (imageFile!.name.contains("png") ||
          imageFile!.name.contains("jpg") ||
          imageFile!.name.contains("jpeg")) {
        var image = await imageFile!.readAsBytes();
        uploadWebImage = image;

        Image image1 = Image.memory(uploadWebImage);
        ImageInfo info = await getImageInfo(image1);

        if (info.image.width > 300 && info.image.height > 50) {
          webImage = uploadWebImage;
          pickImage = io.File(imageFile!.path);
          isUploadSize = false;
        } else {
          isUploadSize = true;
        }
        isAlert = false;
        update();
      } else {
        isAlert = true;
        update();
        await Future.delayed(Durationss.s2);
        isAlert = false;
        update();
      }
    }
  }

  Future getImageAr({source, StateSetter? setState, dropImage, context}) async {
    if (dropImage != null) {
      if (imageNameAr.contains("png") ||
          imageNameAr.contains("jpg") ||
          imageNameAr.contains("jpeg")) {
        var image = dropImage;
        uploadWebImageAr = image;
        Image image1 = Image.memory(uploadWebImageAr);

        ImageInfo info = await getImageInfo(image1);

        if (info.image.width > 300 && info.image.height > 50) {
          webImageAr = uploadWebImageAr;
          pickImageAr = io.File("a");
          isUploadSize = false;
        } else {
          isUploadSize = true;
        }

        isAlert = false;
        update();
      } else {
        isAlert = true;
        update();
        await Future.delayed(Durationss.s2);
        isAlert = false;
        update();
      }
    } else {
      final ImagePicker picker = ImagePicker();
      imageFileAr = (await picker.pickImage(source: ImageSource.gallery))!;

      if (imageFileAr!.name.contains("png") ||
          imageFileAr!.name.contains("jpg") ||
          imageFileAr!.name.contains("jpeg")) {
        var image = await imageFileAr!.readAsBytes();
        uploadWebImageAr = image;

        Image image1 = Image.memory(uploadWebImageAr);
        ImageInfo info = await getImageInfo(image1);

        if (info.image.width > 300 && info.image.height > 50) {
          webImageAr = uploadWebImageAr;
          pickImageAr = io.File(imageFileAr!.path);
          isUploadSize = false;
        } else {
          isUploadSize = true;
        }
        isAlert = false;
        update();
      } else {
        isAlert = true;
        update();
        await Future.delayed(Durationss.s2);
        isAlert = false;
        update();
      }
    }
  }


  Future uploadFile() async {
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);
    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
    } else {
      isLoading = true;
      if (pickImage != null && pickImageAr != null) {
        update();
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = FirebaseStorage.instance.ref().child(fileName);
        UploadTask? uploadTask;
        uploadTask = reference.putData(webImage);

        String fileNameAr = DateTime.now().millisecondsSinceEpoch.toString() + "AR";
        Reference referenceAr = FirebaseStorage.instance.ref().child(fileNameAr);
        UploadTask? uploadTaskAr;
        uploadTaskAr = referenceAr.putData(webImageAr);

        uploadTask.then((res) async {
          res.ref.getDownloadURL().then((downloadUrl) async {
            imageUrl = downloadUrl;
            update();
            uploadTaskAr!.then((resAr) async {
              resAr.ref.getDownloadURL().then((downloadUrlAr) async {
                imageUrlAr = downloadUrlAr;
                update();
                await Future.delayed(Durationss.s3);
                if(imageUrlAr != "" && imageUrlAr.isNotEmpty && imageUrl != "" && imageUrl.isNotEmpty){
                  addNewMainCategoryItem(txtId.text, txtId.text, imageUrl, imageUrlAr ?? imageUrl);
                }else{
                  showAlert(title: "Please choose image first");
                }

              }, onError: (err) {
                update();
              });
            });

          }, onError: (err) {
            update();
          });
        });
      }
    }
  }

  Future uploadFileUpdate(context,oldId,newId) async {
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);
    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
    } else {
      isLoading = true;
      print("Image pick ${pickImage} , Image pick Ar: $pickImageAr , Web image: $webImage , $webImageAr, Image URL: $imageUrl, $imageUrlAr");
      if ((pickImage != null && pickImageAr != null)){
        update();
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = FirebaseStorage.instance.ref().child(fileName);
        UploadTask? uploadTask;
        uploadTask = reference.putData(webImage);

        String fileNameAr = DateTime.now().millisecondsSinceEpoch.toString() + "AR";
        Reference referenceAr = FirebaseStorage.instance.ref().child(fileNameAr);
        UploadTask? uploadTaskAr;
        uploadTaskAr = referenceAr.putData(webImageAr);

        uploadTask.then((res) async {
          res.ref.getDownloadURL().then((downloadUrl) async {
            imageUrl = downloadUrl;
            update();
            uploadTaskAr!.then((resAr) async {
              resAr.ref.getDownloadURL().then((downloadUrlAr) async {
                imageUrlAr = downloadUrlAr;
                update();
                if(imageUrlAr != "" && imageUrlAr.isNotEmpty && imageUrl != "" && imageUrl.isNotEmpty){
                  updateBannerPaths(context,newId, oldId, imageUrl, imageUrlAr ?? imageUrl).then((value) {
                    getData();
                    update();
                    Navigator.of(context).pop();
                    Navigator.pop(context);
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
                  });
                }else{
                  showAlert(title: "Please choose image first");
                }

              }, onError: (err) {
                update();
              });
            });

          }, onError: (err) {
            update();
          });
        });
      }else if ((imageUrl.isNotEmpty && imageUrlAr.isNotEmpty)){
        updateBannerPaths(context,newId, oldId, imageUrl, imageUrlAr ?? imageUrl).then((value) {
          getData();
          update();
          Navigator.of(context).pop();
          Navigator.pop(context);
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
        });
      }
    }
  }


  Future uploadFileAr() async {
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);
    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
    } else {
      isLoading = true;
      if (pickImageAr != null) {
        update();
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = FirebaseStorage.instance.ref().child(fileName);
        UploadTask? uploadTask;
        uploadTask = reference.putData(webImageAr);

        uploadTask.then((res) async {
          res.ref.getDownloadURL().then((downloadUrl) async {
            imageUrlAr = downloadUrl;
            update();
            await Future.delayed(Durationss.s3);
            if(imageUrlAr != "" && imageUrlAr.isNotEmpty){
              getData();
            }else{
              showAlert(title: "Please choose image first");
            }

          }, onError: (err) {
            update();
          });
        });
      } else {
        getData();
      }
    }
  }


  onImagePickUp(setState, context) {
    if (kIsWeb) {
      getImage(source: ImageSource.gallery, context: context);
    } else {
      imagePickerOption(
          setState: setState,
          cameraTap: () {
            getImage(
                source: ImageSource.camera,
                setState: setState,
                context: context);
            Get.back();
          },
          galleryTap: () {
            getImage(
                source: ImageSource.gallery,
                setState: setState,
                context: context);
            Get.back();
          });
    }
  }



  onImagePickUpAr(setState, context) {
    if (kIsWeb) {
      getImageAr(source: ImageSource.gallery, context: context);
    } else {
      imagePickerOption(
          setState: setState,
          cameraTap: () {
            getImage(
                source: ImageSource.camera,
                setState: setState,
                context: context);
            Get.back();
          },
          galleryTap: () {
            getImage(
                source: ImageSource.gallery,
                setState: setState,
                context: context);
            Get.back();
          });
    }
  }

  addBannerDialog({data}) async {
    if (data != null) {
      txtTitle.text = homeCategoryList.where((element) => element.id == data['id']).first.name!;
      txtTitleAr.text = homeCategoryList.where((element) => element.id == data['id']).first.name!;
      txtId.text = data["id"].toString();
      imageUrl = data["bannerPath"];
      imageUrlAr = data['bannerPathAr'];
      isShown = true;
      update();
    } else {
      txtTitle.text = "";
      txtId.text = "";
      idType = "";
      imageUrl = "";
      bannerId = "";
      update();
    }
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AddSectionCatList();
              });
        }).then((value) {
      txtId.clear();
      txtTitleAr.clear();
      txtTitle.clear();
    });
  }

  updateBannerDialog({data}) async {
    if (data != null) {
      txtTitle.text = homeCategoryList.where((element) => element.id == data['id']).first.name!;
      txtTitleAr.text = homeCategoryList.where((element) => element.id == data['id']).first.name!;
      txtId.text = data["id"].toString();
      imageUrl = data["bannerPath"];
      imageUrlAr = data['bannerPathAr'];
      isShown = true;
      update();
    } else {
      txtTitle.text = "";
      txtId.text = "";
      idType = "";
      imageUrl = "";
      bannerId = "";
      update();
    }
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return UpdateSectionCatList(currentId: data['id'] ?? "".toString(),);
              });
        }).then((value) {
      txtId.clear();
      txtTitleAr.clear();
      txtTitle.clear();
    });
  }

  Future<void> deleteCategory(String itemId) async {
    print("Deleting item from Firestore for itemId: $itemId");

    try {
      // Retrieve the document
      DocumentReference<Map<String, dynamic>> documentReference =
      FirebaseFirestore.instance.collection("homeCategorySlider").doc('QhYlLUCSusla8bZheQ5g');

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        // Get the existing data
        Map<String, dynamic> existingData = documentSnapshot.data()!;

        // Remove the item from 'mainCategoryAr' list based on 'id'
        existingData['mainCategoryAr'].removeWhere((item) => item['id'] == itemId);

        // Update the document with the modified data
        await documentReference.update(existingData);

        homeCategoryView.removeWhere((element) => element.id == itemId);

        print("Firestore delete successful for categoryId: $itemId, itemId: $itemId");

        await getData();

        homeCategoryView.toList().toSet();

        update();
      } else {
        print("Document not found for categoryId: $itemId");
      }
    } catch (error) {
      print("Error deleting item from Firestore for categoryId: $itemId, itemId: $itemId, Error: $error");
    }
  }

  Future<void> updateBannerPaths(context,String categoryId, String itemId, String newBannerPath, String newBannerPathAr) async {
    print("Updating banner paths for categoryId: $categoryId, itemId: $itemId");

    try {

      var myDialog =
      showDialog(context: context, builder: (context) => SizedBox(
        width: 50,
        height: 50,
        child: Center(child: CircularProgressIndicator(),),),);
      // Retrieve the document
      DocumentReference<Map<String, dynamic>> documentReference =
      FirebaseFirestore.instance.collection("homeCategorySlider").doc('QhYlLUCSusla8bZheQ5g');

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        // Get the existing data
        Map<String, dynamic> existingData = documentSnapshot.data()!;

        // Find the index of the item in the 'mainCategoryAr' list
        int index = existingData['mainCategoryAr'].indexWhere((item) => item['id'] == itemId);

        // If the item with 'id' is found, update its 'bannerPath' and 'bannerPathAr'
        if (index != -1) {
          existingData['mainCategoryAr'][index]['bannerPath'] = newBannerPath;
          existingData['mainCategoryAr'][index]['bannerPathAr'] = newBannerPathAr ?? newBannerPath;
          existingData['mainCategoryAr'][index]['id'] = categoryId;
        } else {
          print("Item with itemId: $itemId not found in mainCategoryAr list");
          return;
        }

        // Update the document with the modified data
        await documentReference.update(existingData);

        //await Future.delayed(Duration(seconds: 2));

        update();

        // var scaffoldDrawerKey = GlobalKey<ScaffoldState>(debugLabel: "drawer");
        // var scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "key2");
        //
        // IndexLayoutController indexCtrl = Get.isRegistered<IndexLayoutController>() ? Get.find<IndexLayoutController>() : Get.put(IndexLayoutController());
        //
        // indexCtrl.selectedIndex = 3;
        // indexCtrl.update();
        // Get.offAll(() => IndexLayout(scaffoldDrawerKey: scaffoldDrawerKey,scaffoldKey: scaffoldKey,));



        print("Firestore update successful for categoryId: $categoryId, itemId: $itemId");
      } else {
        print("Document not found for categoryId: $categoryId");
      }
    } catch (error) {
      print("Error updating banner paths for categoryId: $categoryId, itemId: $itemId, Error: $error");
    }
  }

  Future<void> addNewMainCategoryItem(String categoryId, String itemId, String bannerPath, String bannerPathAr) async {
    print("Adding new item to Firestore for categoryId: $categoryId");

    try {
      // Retrieve the document
      DocumentReference<Map<String, dynamic>> documentReference =
      FirebaseFirestore.instance.collection("homeCategorySlider").doc('QhYlLUCSusla8bZheQ5g');

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        // Get the existing data
        Map<String, dynamic> existingData = documentSnapshot.data()!;

        // Create a new item with the provided attributes
        Map<String, dynamic> newItem = {
          'id': itemId,
          'bannerPath': bannerPath,
          'bannerPathAr': bannerPathAr,
          'priority': homeCategoryView.length + 1,
        };

        // Add the new item to the 'mainCategoryAr' list
        existingData['mainCategoryAr'].add(newItem);


        // Update the document with the modified data
        await documentReference.update(existingData);

        getData();

        Get.back();

        print("Firestore update successful for categoryId: $categoryId");
      } else {
        print("Document not found for categoryId: $categoryId");
      }
    } catch (error) {
      print("Error adding new item to Firestore for categoryId: $categoryId, Error: $error");
    }
  }


}