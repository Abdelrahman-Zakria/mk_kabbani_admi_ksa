import 'dart:async';
import 'dart:html';
import 'dart:io' as io;
import 'dart:js';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:developer' as log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/add_banner_home_sections.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/add_product_home_section.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/update_banner_home_section.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../config.dart';
import 'package:mk_kabbani_admin/shopify/shopify_mixin.dart';
import 'package:mk_kabbani_admin/models/category_model.dart' as cat;
import 'package:mk_kabbani_admin/models/product_model.dart' as product_model;




class HomeSectionsController extends GetxController with ShopifyMixin{
  List<DatatableHeader>? homeSectionsHeaders;
  late DropzoneViewController? controller1;
  late DropzoneViewController? controllerChild;
  late DropzoneViewController? controller2;

  final List<int> perPages = [10, 20, 50, 100];
  int total = 100;
  int? currentPerPage = 10;
  List<bool>? expanded;
  String? searchKey = "id";
  XFile? imageFile;
  XFile? imageFileChild;

  XFile? imageFileAr;

  int currentPage = 1;
  bool isSearch = false, isUploadSize = false, isAlert = false;
  final List<Map<String, dynamic>> sourceOriginal = [];
  List<Map<String, dynamic>> sourceFiltered = [];
  List<Map<String, dynamic>> source = [];
  List<Map<String, dynamic>> selected = [];
  String imageName = "", imageUrl = "";
  String imageNameChild = "", imageUrlChild = "";

  String imageNameAr = "", imageUrlAr = "";

  Uint8List webImage = Uint8List(8);
  Uint8List webImageChild = Uint8List(8);

  Uint8List webImageAr = Uint8List(8);

  bool? isShown;
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtTitleAr = TextEditingController();

  TextEditingController txtId = TextEditingController();
  TextEditingController addNewId = TextEditingController();
  TextEditingController addNewTitle = TextEditingController();
  TextEditingController addNewBanner = TextEditingController();
  Rx<String?>? newSubColSelectedItem;

  Rx<bool>? isSectionShown = false.obs;




  // ignore: unused_field
  final String selectableKey = "id";
  String idType = "", bannerId = "";
  String? sortColumn;
  Uint8List uploadWebImage = Uint8List(8);
  Uint8List uploadWebImageChild = Uint8List(8);

  Uint8List uploadWebImageAr = Uint8List(8);


  bool sortAscending = true;
  bool isLoading = true;
  bool isLoadingProd = true;

  bool isLoadingChild = false;

  final bool showSelect = true;
  io.File? pickImage;
  io.File? pickImageChild;

  io.File? pickImageAr;

  List homeSections = [];
  List? sectionChildren = [];
  var random = Random();
  List<cat.Category> homeCategoryList = [];
  List<product_model.Product> productList = [];


  List<Map<String, dynamic>> _generateData() {
    print("Home sections length: ${homeSections.length}");
    List source = homeSections.toSet().toList();
    List<Map<String, dynamic>> temps = [];
    var i = 1;
    if (kDebugMode) {
      print(i);
    }
    // ignore: unused_local_variable
    for (var data in source) {
      temps.add({
        "collectionId": data['collectionId'],
        "bannerPath": data['bannerPath'],
        "title": data['title'],
        "isShown": true,
        "action": i,
        "titleAr":data['titleAr'],
      });
      i++;
    }
    return temps;
  }


   getHomeSections()async{
    homeSections.clear();
    await FirebaseFirestore.instance
        .collection("homeSections")
        .get()
        .then((value) {
          print("Docs length: ${value.docs.length}");
      value.docs.asMap().entries.forEach((element) {
        print("Doc data: ${element.value.data()['collectionId']}");
          homeSections.add(element.value.data());
          update();
          // homeSections.forEach((e) {
          //   if(e['collectionId'] == element.value.data()['collectionId']){
          //     homeSections.remove(e);
          //   }
          // });

      });
    });
    // homeSections.sort((a, b) =>
    //     homeSections
    //         .firstWhere((element) => element['collectionId'] == a['collectionId'])['priority']
    //         .compareTo(
    //         homeSections
    //             .firstWhere((element) => element['collectionId'] == b['collectionId'])['priority']));



    update();
    print("From home sections: ${homeSections.length}");
    return homeSections;
  }

  initializeData() async {
    mockPullData();
  }

  getSectionIsShown(id)async{
    try{
      var doc = await FirebaseFirestore.instance.collection("homeSections").where('collectionId', isEqualTo: id).get();
      isSectionShown!.value = doc.docs[0].data()['isShown'];
      print("From is SHOW: ${doc.docs[0]['collectionId']} ${doc.docs[0].data()['isShown']}");
      update();
    }catch(error){
      isSectionShown!.value = false;
      update();
    }

  }

  changeNewSectionId(newId){
    addNewId.text = newId;
    addNewTitle.text = homeCategoryList.where((element) => element.id == newId).toList()[0].name!;
    addNewBanner.text = homeCategoryList.where((element) => element.id == newId).toList()[0].image!;
    update();
  }

  changeNewProductId(newId){
    addNewId.text = newId;
    addNewTitle.text = productList.where((element) => element.id == newId).toList()[0].name!;
    addNewBanner.text = productList.where((element) => element.id == newId).toList()[0].images[0]!;
    update();
  }


  void updatePrioritiesInFirestore(BuildContext context, int oldIndex, int newIndex) async {
    String categoryId1 = homeSections[oldIndex]['collectionId'];
    String categoryId2 = homeSections[newIndex]['collectionId'];

    int oldPriority1 = homeSections.firstWhere((element) => element['collectionId'] == categoryId1)['priority'];
    int oldPriority2 = homeSections.firstWhere((element) => element['collectionId'] == categoryId2)['priority'];

    // Swap priorities
    int newPriority1 = oldPriority2;
    int newPriority2 = oldPriority1;



    // Update category 1 in Firestore
    await updateFirestorePriority(categoryId1, newPriority1);

    // Update category 2 in Firestore
    await updateFirestorePriority(categoryId2, newPriority2);

    // Update the priority in the local list for category 1
    homeSections
        .firstWhere((element) => element['collectionId'] == categoryId1)['priority'] =
        newPriority1;

    // Update the priority in the local list for category 2
    homeSections
        .firstWhere((element) => element['collectionId'] == categoryId2)['priority'] =
        newPriority2;

    // Sort the switchValues based on the updated priorities
    homeSections.sort((a, b) =>
        a['priority'].compareTo(b['priority']));

    // Trigger a rebuild of the UI
    update();

    // Delay to show CircularProgressIndicator for a short duration

    // Pop the dialog
  }

// Function to update priority in Firestore
  Future<void> updateFirestorePriority(String categoryId, int newPriority) async {
    print("Updating Firestore for categoryId: $categoryId, newPriority: $newPriority");

    // Use .where('id', isEqualTo: categoryId) for the query
    await FirebaseFirestore.instance
        .collection("homeSections")
        .where('collectionId', isEqualTo: categoryId)
        .get()
        .then((querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({'priority': newPriority})
            .then((value) {
          print("Firestore update successful for categoryId: $categoryId");
        }).catchError((error) {
          print("Error updating Firestore for categoryId: $categoryId, Error: $error");
        });
      } else {
        print("Document not found for categoryId: $categoryId");
      }
    });
  }

  //add banner
  saveHomeSection(context) async {
    isLoading = true;
    update();

    try {
      if (txtId.text != "") {
        int id = DateTime.now().millisecondsSinceEpoch;
        if(imageUrl.isNotEmpty && imageUrlAr.isNotEmpty){
          await FirebaseFirestore.instance.collection("homeSections").add({
            "collectionId": txtId.text,
            "bannerPath": imageUrl,
            'bannerPathAr' : imageUrlAr,
            "title": txtTitle.text,
            "children" : [],
            'priority' : homeSections.length + 1,
            "titleAr" : txtTitleAr.text,
            "isShown":true,
          }).then((value) {
            isLoading = false;
            update();
            Get.back();
            txtTitle.text = "";
            txtTitleAr.text = '';
            txtId.text = "";
            idType = "";
            imageFile =null;
            webImage = Uint8List(8);
            imageUrl ="";
            initializeData();

          });
        }
        else{
          showDialog(context: context,builder: (context) => AlertDialog(content: Text("Please choose image first"),),);
        }
      }

      // else {
      //
      //   await FirebaseFirestore.instance
      //       .collection("homeSections")
      //       .get()
      //       .then((value) {
      //     value.docs.asMap().entries.forEach((element) {
      //       if (bannerId.toString() ==
      //           element.value.data()["collectionId"].toString()) {
      //         FirebaseFirestore.instance
      //             .collection("homeSections")
      //             .doc(element.value.id)
      //             .update({
      //           "collectionId": txtId.text,
      //           "bannerPath": imageUrl,
      //           'bannerPathAr' : imageUrlAr,
      //           "title": txtTitle.text,
      //           "titleAr" : txtTitleAr.text,
      //           "children" : [],
      //           'priority' : homeSections.length + 1,
      //           "isShown":true,
      //         }).then((value) {
      //           txtTitle.text = "";
      //           txtTitleAr.text = '';
      //           txtId.text = "";
      //           idType = "";
      //           imageFile =null;
      //           webImage = Uint8List(8);
      //           imageUrl ="";
      //         });
      //       }
      //     });
      //   });
      // }
      getHomeSections().then((val){
        homeSections.sort((a,b)=>a['priority'].compareTo(b['priority']));
      });

    } catch (e) {
      log.log("save error: $e");
    } finally {
      isLoading = false;
      Get.back();
      initialSetUi();
      initializeData();
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
      update();
    }
  }

  Future<void> updateSectionCollectionId(context,{
    required String collectionId,
    required String newTitle,
    required String newTitleAr,
    required String newImageUrl,
    required String newImageUrlAr,
  }) async {
    try {
      // Reference to the collection
      CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("homeSections");

      // Query to find the document with the specified collectionId
      QuerySnapshot querySnapshot =
      await collectionReference.where("collectionId", isEqualTo: collectionId).get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Update the first document found (assuming collectionId is unique)
        DocumentReference documentReference = querySnapshot.docs.first.reference;

        // Update the document with the new data
        await documentReference.update({
          "title": newTitle,
          "titleAr": newTitleAr,
          "bannerPath": newImageUrl,
          "bannerPathAr": newImageUrlAr,
        }).then((value) {
          isLoading = false;
          getHomeSections().then((val){
            homeSections.sort((a,b)=> a['priority'].compareTo(b['priority']));
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
        });

        print("Document updated successfully");
      } else {
        print("No document found with collectionId: $collectionId");
        // Handle the case where no document is found with the given collectionId
      }
    } catch (e) {
      print("Error updating document: $e");
      // Handle errors as needed
    }
  }

  //list data
  mockPullData() async {
    expanded = List.generate(currentPerPage!, (index) => false);

    isLoading = true;

    Future.delayed(const Duration(seconds: 3)).then((value) {
      sourceOriginal.clear();
      sourceOriginal.addAll(_generateData());

      sourceFiltered = sourceOriginal;
      total = sourceFiltered.length;
      if (sourceFiltered.length > 5) {
       // source = sourceFiltered.getRange(0, currentPerPage!).toList();
        source = sourceFiltered;
      } else {
        source = sourceFiltered;
      }

      isLoading = false;
      update();
    });
  }

//add banner dialog
  addBannerDialog({data}) async {
    if (data != null) {
      txtTitle.text = data["title"];
      txtTitleAr.text = data["titleAr"];
      txtId.text = data["collectionId"].toString();
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
      imageUrlAr = "";
      webImage = Uint8List(8);
      webImageAr = Uint8List(8);
      update();
    }
    log.log("bannerId : $bannerId");
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                print("From adddddd: ${sectionChildren!.length}");
                getSectionChildren(txtId.text);
                return AddSection(childrenList: sectionChildren,);
              });
        }).then((value) {
          sectionChildren!.clear();
          txtId.clear();
          txtTitleAr.clear();
          txtTitle.clear();
    });
  }

  addProductDialog({data}) async {
    if (data != null) {
      txtTitle.text = data["title"];
      txtTitleAr.text = data["titleAr"];
      txtId.text = data["collectionId"].toString();
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
      imageUrlAr = "";
      webImage = Uint8List(8);
      webImageAr = Uint8List(8);
      update();
    }
    log.log("bannerId : $bannerId");
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                print("From adddddd: ${sectionChildren!.length}");
                getSectionChildren(txtId.text);
                return AddProduct(childrenList: sectionChildren,);
              });
        }).then((value) {
      sectionChildren!.clear();
      txtId.clear();
      txtTitleAr.clear();
      txtTitle.clear();
    });
  }


  updateBannerDialog({data}) async {
    if (data != null) {
      txtTitle.text = data["title"];
      txtTitleAr.text = data["titleAr"];
      txtId.text = data["collectionId"].toString();
      imageUrl = data["bannerPath"];
      imageUrlAr = data['bannerPathAr'];
      sectionChildren = data['children']??[];
      isShown = data['isShown'];
      update();
    } else {
      txtTitle.text = "";
      txtId.text = "";
      idType = "";
      imageUrl = "";
      bannerId = "";
      imageUrlAr = "";
      isShown = false;
      update();
    }
    log.log("bannerId : $bannerId");
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                print("From adddddd: ${sectionChildren!.length}");
                getSectionChildren(txtId.text);
                return UpdateSection(childrenList: sectionChildren,);
              });
        }).then((value) {
      sectionChildren!.clear();
      txtId.clear();
      txtTitleAr.clear();
      txtTitle.clear();
    });
  }

  //reset data
  resetData({start = 0}) async {
    isLoading = true;
    update();
    var expandedLen =
    total - start < currentPerPage! ? total - start : currentPerPage;
    Future.delayed(const Duration(seconds: 0)).then((value) {
      expanded = List.generate(expandedLen as int, (index) => false);
      source.clear();
      source = sourceFiltered.getRange(start, start + expandedLen).toList();
      isLoading = false;
      update();
    });
  }

  //filter data
  filterData(value) {
    isLoading = true;
    update();

    try {
      if (value == "" || value == null) {
        sourceFiltered = sourceOriginal;
      } else {
        sourceFiltered = sourceOriginal
            .where((data) => data[searchKey!]
            .toString()
            .toLowerCase()
            .contains(value.toString().toLowerCase()))
            .toList();
      }

      total = sourceFiltered.length;
      var rangeTop = total < currentPerPage! ? total : currentPerPage!;
      expanded = List.generate(rangeTop, (index) => false);
      source = sourceFiltered.getRange(0, rangeTop).toList();
    } catch (e) {
      log.log("filter error : $e");
    }
    isLoading = false;
    update();
  }

  //on click Image

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

  onImagePickUpChild(setState, context) {
    if (kIsWeb) {
      getImageChild(source: ImageSource.gallery, context: context);
    } else {
      imagePickerOption(
          setState: setState,
          cameraTap: () {
            getImageChild(
                source: ImageSource.camera,
                setState: setState,
                context: context);
            Get.back();
          },
          galleryTap: () {
            getImageChild(
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
            getImageAr(
                source: ImageSource.camera,
                setState: setState,
                context: context);
            Get.back();
          },
          galleryTap: () {
            getImageAr(
                source: ImageSource.gallery,
                setState: setState,
                context: context);
            Get.back();
          });
    }
  }


  Future<List> getSectionChildren(id)async{
    print("Collection get children: ${id}");
    var collectionData = await FirebaseFirestore.instance
        .collection("homeSections")
        .where("collectionId", isEqualTo: id.toString().trim())
        .get();
    List children = collectionData.docs[0]['children'];
    print("Children list: "+children.length.toString());
    for(var child in children){
      print("Get children done: ${child['id']}");
    }
    sectionChildren = children;
    update();
    return children;

  }

  initialSetUi() async {
    String imageUrl = "image_url";
    // https://github.com/flutter/flutter/issues/41563
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      imageUrl,
          (int _) => ImageElement()..src = imageUrl,
    );
    // getHomeSections();
    homeSectionsHeaders = [
      DatatableHeader(
          text: "ID",
          value: "collectionId",
          show: true,
          sortable: true,
          flex: 1,
          textAlign: TextAlign.center),
      DatatableHeader(
          text: "Image",
          value: "bannerPath",
          show: true,
          sortable: false,
          sourceBuilder: (value, row) {
            return Image(
              image: NetworkImage(value),
              height: Sizes.s100,
            ).marginSymmetric(horizontal: Insets.i10);
          },
          textAlign: TextAlign.center),
      DatatableHeader(
          text: "Name",
          value: "title",
          show: true,
          sortable: true,
          textAlign: TextAlign.center),
      DatatableHeader(
          text: "Is Active",
          value: "isShown",
          show: true,
          sortable: true,
          textAlign: TextAlign.center),
      DatatableHeader(
          text: "Actions",
          value: "action",
          show: true,
          sortable: false,
          sourceBuilder: (value, row) {
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: OutlinedButton(
                          onPressed: () {
                            updateBannerDialog(data: row);
                          },
                          child: const Icon(Icons.edit, size: Sizes.s18))),
                  OutlinedButton(
                      onPressed: () async {
                        log.log("vad L ${row["id"]}");
                        bool isLoginTest = appCtrl.storage.read(session.isLoginTest);
                        if (isLoginTest) {
                          accessDenied(fonts.modification.tr);
                        }else {
                          await FirebaseFirestore.instance
                              .collection("homeSections")
                              .where("collectionId", isEqualTo: row["id"])
                              .get()
                              .then((value) {
                            if (value.docs.isNotEmpty) {
                              FirebaseFirestore.instance
                                  .collection("homeSections")
                                  .doc(value.docs[0].id)
                                  .delete().then((value) => getHomeSections().then((val){
                                return homeSections.sort((a, b) =>
                                    a['priority'].compareTo(b['priority']));
                              }));

                            }
                          });
                          initialSetUi();


                          initializeData();

                          getData();
                          update();
                        }
                      },
                      child: const Icon(Icons.delete, size: Sizes.s18))
                ]);
          },
          textAlign: TextAlign.center,
      ),
    ];

    isLoading = false;
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    initialSetUi();
    update();
    initializeData();
    getHomeSections().then((val){
      return homeSections.sort((a, b) =>
          a['priority'].compareTo(b['priority']));
    });
    getData();

    super.onInit();
  }

  getData()async{
    log.log("Get data started");
    homeCategoryList = await shopifyService.getCategoriesByCursor();
    for(cat.Category category in homeCategoryList){
      print("Title ${category.name} , id: ${category.id} , banner: ${category.image ?? ""}");
    }

    productList  = await shopifyService.getAllProduct();

    for(product_model.Product product in productList){
      print("Product Title ${product.name} , id: ${product.id} , banner: ${product.images[0] ?? ""}");
    }
    productList.sort((a, b) => a.name!.compareTo(b.name!));
    update();
  }

// GET IMAGE FROM GALLERY
  Future getImage({source, StateSetter? setState, dropImage, context}) async {
    if (dropImage != null) {
      if (imageName.contains("png") ||
          imageName.contains("jpg") ||
          imageName.contains("jpeg")) {
        var image = dropImage;
        uploadWebImage = image;
        log.log("uploadWebImage : $uploadWebImage");
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
      log.log("imageFile : $imageFile");

      if (imageFile!.name.contains("png") ||
          imageFile!.name.contains("jpg") ||
          imageFile!.name.contains("jpeg")) {
        var image = await imageFile!.readAsBytes();
        uploadWebImage = image;

        Image image1 = Image.memory(uploadWebImage);
        log.log("image1 : $image1");
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

  Future getImageChild({source, StateSetter? setState, dropImage, context}) async {
    if (dropImage != null) {
      if (imageNameChild.contains("png") ||
          imageNameChild.contains("jpg") ||
          imageNameChild.contains("jpeg")) {
        var image = dropImage;
        uploadWebImageChild = image;
        log.log("uploadWebImage : $uploadWebImageChild");
        Image image1 = Image.memory(uploadWebImageChild);

        ImageInfo info = await getImageInfo(image1);

        if (info.image.width > 300 && info.image.height > 50) {
          webImageChild = uploadWebImageChild;
          pickImageChild = io.File("c");
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
      imageFileChild = (await picker.pickImage(source: ImageSource.gallery))!;
      log.log("imageFile : $imageFileChild");

      if (imageFileChild!.name.contains("png") ||
          imageFileChild!.name.contains("jpg") ||
          imageFileChild!.name.contains("jpeg")) {
        var image = await imageFileChild!.readAsBytes();
        uploadWebImageChild = image;

        Image image1 = Image.memory(uploadWebImageChild);
        log.log("image1 : $image1");
        ImageInfo info = await getImageInfo(image1);

        if (info.image.width > 300 && info.image.height > 50) {
          webImageChild = uploadWebImageChild;
          pickImageChild = io.File(imageFileChild!.path);
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
        log.log("uploadWebImage : $uploadWebImageAr");
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
      log.log("imageFile : $imageFileAr");

      if (imageFileAr!.name.contains("png") ||
          imageFileAr!.name.contains("jpg") ||
          imageFileAr!.name.contains("jpeg")) {
        var image = await imageFileAr!.readAsBytes();
        uploadWebImageAr = image;

        Image image1 = Image.memory(uploadWebImageAr);
        log.log("image1 : $image1");
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


  Future<void> addMapToChildren(String documentId, Map<String, dynamic> newMap) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Retrieve the document from Firestore
      var collections =  await firestore
          .collection('homeSections')
          .where('collectionId', isEqualTo: documentId)
          .get();

      DocumentSnapshot documentSnapshot = collections.docs[0];

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Step 2: Modify the list in memory by adding the new map
        Map data = documentSnapshot.data() as Map;

        List children = data['children'] ?? [];

        children.add(newMap);

        // Step 3: Update the document in Firestore with the modified list
        await firestore.collection('homeSections').doc(documentSnapshot.id).update({'children': children});

        getSectionChildren(documentId);
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error adding map to children: $e');
    }
  }

  Future<void> updateChildBannerPath(
      String documentId, String idToUpdate, String updatedBannerPath) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Retrieve the document from Firestore
      var collections = await firestore
          .collection('homeSections')
          .where('collectionId', isEqualTo: documentId)
          .get();

      DocumentSnapshot documentSnapshot = collections.docs[0];

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Step 2: Modify the list in memory by updating the specific map
        Map data = documentSnapshot.data() as Map;

        List<Map<String, dynamic>> children =
        List<Map<String, dynamic>>.from(data['children'] ?? []);

        // Identify the 'id' of the map you want to update
        int indexOfMapToUpdate = -1; // Initialize to -1 if not found

        for (int i = 0; i < children.length; i++) {
          if (children[i]['id'] == idToUpdate) {
            indexOfMapToUpdate = i;
            break; // Exit the loop once you find the map to update
          }
        }

        if (indexOfMapToUpdate != -1) {
          // Create an updated map with the new banner path
          Map<String, dynamic> updatedMap = {
            'id': idToUpdate, // Keep the same 'id'
            'bannerPath': updatedBannerPath, // Update the banner path
            // Add other fields you want to update here
          };

          // Update the specific map in the list
          children[indexOfMapToUpdate] = updatedMap;
        } else {
          print('Map with ID $idToUpdate not found for update.');
          return; // Exit if the map to update was not found
        }

        // Step 3: Update the document in Firestore with the modified list
        await firestore
            .collection('homeSections')
            .doc(documentSnapshot.id)
            .update({'children': children});

        print("Section child banner updated");

        await getSectionChildren(documentId);
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error updating map in children: $e');
    }
  }


  Future<void> deleteChildAndShowConfirmation(
      BuildContext context, String documentId, String idToDelete) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      var collections = await firestore
          .collection('homeSections')
          .where('collectionId', isEqualTo: documentId)
          .get();

      DocumentSnapshot documentSnapshot = collections.docs[0];

      // Check if the document exists
      if (documentSnapshot.exists) {
        Map data = documentSnapshot.data() as Map;

        List<Map<String, dynamic>> children =
        List<Map<String, dynamic>>.from(data['children'] ?? []);

        // Identify the index of the map to delete
        int indexOfMapToDelete = -1; // Initialize to -1 if not found

        for (int i = 0; i < children.length; i++) {
          if (children[i]['id'] == idToDelete) {
            indexOfMapToDelete = i;
            break; // Exit the loop once you find the map to delete
          }
        }

        if (indexOfMapToDelete != -1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: Text('Are you sure you want to delete this item?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Delete'),
                    onPressed: () async {
                      // Remove the map from the list
                      children.removeAt(indexOfMapToDelete);

                      // Update the document in Firestore with the modified list
                      await firestore
                          .collection('homeSections')
                          .doc(documentSnapshot.id)
                          .update({'children': children});

                      await getSectionChildren(documentId);

                      Navigator.of(context).pop();
                      Navigator.pop(context);


                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          content: Text(
                            "Deleted successfully",
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
                      );// Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        } else {
          print('Map with ID $idToDelete not found for deletion.');
          return; // Exit if the map to delete was not found
        }
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error deleting map from children: $e');
    }
  }



  Future<void> updateSectionStatus(String documentId, bool isShown) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Retrieve the document from Firestore
      var collections =  await firestore
          .collection('homeSections')
          .where('collectionId', isEqualTo: documentId)
          .get();

      DocumentSnapshot documentSnapshot = collections.docs.first;

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Step 2: Modify the list in memory by adding the new map
        // Map data = documentSnapshot.data() as Map;
        //
        // List children = data['children'] ?? [];
        //
        // children.add(newMap);

        // Step 3: Update the document in Firestore with the modified list
        await firestore.collection('homeSections').doc(documentSnapshot.id).update({'isShown': isShown});
        print("Section updated: $isShown");
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error adding map to children: $e');
    }
  }


  Future<void> uploadFileChild(context,docId,childId,bannerPath) async {
    isLoadingChild = true;
    update();
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);

    var myDialog =
    showDialog(context: context, builder: (context) => SizedBox(
      width: 50,
        height: 50,
        child: Center(child: CircularProgressIndicator(),),),);

    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
      return;
    }

    update();

    try {
      if (pickImageChild != null) {
        String fileNameChild = DateTime.now().millisecondsSinceEpoch.toString() + "child";
        Reference reference = FirebaseStorage.instance.ref().child(fileNameChild);

        // Parallelize image uploads
        final List<UploadTask> uploadTasks = [
          reference.putData(webImageChild),
        ];

        await Future.wait(uploadTasks);

// Continue with your code after the uploads have completed
        final List<String> downloadUrls = await Future.wait([
          reference.getDownloadURL(),
        ]);

        imageUrlChild = downloadUrls[0];

        log.log("imageUrlChild: $imageUrlChild");


        if (imageUrlChild.isNotEmpty) {
          print("ADDING $imageUrlChild, ID: ${txtId.text}");
          await updateChildBannerPath(docId,childId,imageUrlChild);
        } else {
          showAlert(title: "Please choose image first");
        }
      } else {
        // Handle case when images are not selected
        showAlert(title: "Please choose image first");
      }
    } catch (error) {
      // Handle errors
      print("Error uploading images: $error");
    } finally {
      Navigator.of(context).pop();
      Navigator.pop(context);
      Navigator.pop(context);
      imageUrlChild = "";
      webImageChild.clear();
      pickImageChild!.delete();
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

      isLoadingChild = false;
      update();
    }
  }


  Future<void> uploadFileAddChild(context,docId,childId,bannerPath) async {
    isLoadingChild = true;
    update();
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);

    var myDialog =
    showDialog(context: context, builder: (context) => SizedBox(
      width: 50,
      height: 50,
      child: Center(child: CircularProgressIndicator(),),),);

    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
      return;
    }

    update();

    try {
      if (pickImageChild != null) {
        String fileNameChild = DateTime.now().millisecondsSinceEpoch.toString() + "child";
        Reference reference = FirebaseStorage.instance.ref().child(fileNameChild);

        // Parallelize image uploads
        final List<UploadTask> uploadTasks = [
          reference.putData(webImageChild),
        ];

        await Future.wait(uploadTasks);

// Continue with your code after the uploads have completed
        final List<String> downloadUrls = await Future.wait([
          reference.getDownloadURL(),
        ]);

        imageUrlChild = downloadUrls[0];

        log.log("imageUrlChild: $imageUrlChild");


        if (imageUrlChild.isNotEmpty) {
          print("ADDING $imageUrlChild, ID: ${txtId.text}");
          await addMapToChildren(
              docId,
              {
                "id": childId,
                "bannerPath": imageUrlChild,
              });

        } else {
          showAlert(title: "Please choose image first");
        }
      } else {
        // Handle case when images are not selected
        showAlert(title: "Please choose image first");
      }
    } catch (error) {
      // Handle errors
      print("Error uploading images: $error");
    } finally {
      Navigator.of(context).pop();
      Navigator.pop(context);
      Navigator.pop(context);
      imageUrlChild = "";
      webImageChild.clear();
      pickImageChild!.delete();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            "Added successfully",
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

      isLoadingChild = false;
      update();
    }
  }

  Future<void> uploadFileAddChildProd(context,docId,childId,bannerPath) async {
    isLoadingChild = true;
    update();
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);

    var myDialog =
    showDialog(context: context, builder: (context) => SizedBox(
      width: 50,
      height: 50,
      child: Center(child: CircularProgressIndicator(),),),);

    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
      return;
    }

    update();

    try {
      await addMapToChildren(
          docId,
          {
            "id": childId,
            "bannerPath": "",
          });
    } catch (error) {
      // Handle errors
      print("Error uploading images: $error");
    } finally {
      Navigator.of(context).pop();
      Navigator.pop(context);
      Navigator.pop(context);
      imageUrlChild = "";
      webImageChild.clear();
      pickImageChild!.delete();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            "Added successfully",
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

      isLoadingChild = false;
      update();
    }
  }




// UPLOAD SELECTED IMAGE TO FIREBASE
  Future<void> uploadFile(context) async {
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);

    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
      return;
    }

    isLoading = true;
    update();

    try {
      if (pickImageAr != null && pickImage != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        String fileNameEn = DateTime.now().millisecondsSinceEpoch.toString() + "EN";
        Reference reference = FirebaseStorage.instance.ref().child(fileName);
        Reference referenceEn = FirebaseStorage.instance.ref().child(fileNameEn);

        // Parallelize image uploads
        final List<UploadTask> uploadTasks = [
          reference.putData(webImageAr),
          referenceEn.putData(webImage),
        ];

        await Future.wait(uploadTasks);

// Continue with your code after the uploads have completed
        final List<String> downloadUrls = await Future.wait([
          reference.getDownloadURL(),
          referenceEn.getDownloadURL(),
        ]);

        imageUrlAr = downloadUrls[0];
        imageUrl = downloadUrls[1];

        log.log("imageUrlEN: $imageUrl");
        log.log("imageUrlAr: $imageUrlAr");


        if (imageUrlAr.isNotEmpty && imageUrl.isNotEmpty) {
          print("ADDING $imageUrl, ID: ${txtId.text}");
          saveHomeSection(context);
        } else {
          showAlert(title: "Please choose image first");
        }
      } else {
        // Handle case when images are not selected
        showAlert(title: "Please choose image first");
      }
    } catch (error) {
      // Handle errors
      print("Error uploading images: $error");
    } finally {
      isLoading = false;
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
      update();
    }
  }

  Future uploadFileUpdate(context) async {
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);
    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
    } else {
      isLoading = true;
      if (pickImage != null) {
        update();
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = FirebaseStorage.instance.ref().child(fileName);
        log.log("reference : $webImage");
        UploadTask? uploadTask;
        uploadTask = reference.putData(webImage);
        uploadTask.then((res) async {
          log.log("res : $res");
          res.ref.getDownloadURL().then((downloadUrl) async {
            imageUrl = downloadUrl;
            log.log("imageUrl : $imageUrl");
            update();
            await Future.delayed(Durationss.s3);
            if(imageUrl != "" && imageUrl.isNotEmpty){
            }else{
              showAlert(title: "Please choose image first");
            }

          }, onError: (err) {
            update();
          });
        });
      } else {
        Get.back();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Text(
              "Please choose image first",
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
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

      }
      if (pickImageAr != null) {
        update();
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = FirebaseStorage.instance.ref().child(fileName);
        log.log("reference : $webImageAr");
        UploadTask? uploadTask;
        uploadTask = reference.putData(webImageAr);

        uploadTask.then((res) async {
          log.log("res : $res");
          res.ref.getDownloadURL().then((downloadUrl) async {
            imageUrlAr = downloadUrl;
            log.log("imageUrlEN : $imageUrl");
            log.log("imageUrlAr :  $imageUrlAr");
            update();
            await Future.delayed(Durationss.s3);
            if(imageUrlAr != "" && imageUrlAr.isNotEmpty){
              await updateSectionCollectionId(context,collectionId: txtId.text, newTitle: txtTitle.text, newTitleAr: txtTitleAr.text, newImageUrl: imageUrl, newImageUrlAr: imageUrlAr);
              Get.back();
            }else{
              showAlert(title: "Please choose image first");
            }

          }, onError: (err) {
            update();
          });
        });
      } else {
        Get.back();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Text(
              "Please choose image first",
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
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

      }
    }
  }



  //on sort
  onSort(value) async {
    isLoading = true;
    update();

    sortColumn = value;
    sortAscending = !sortAscending;
    if (sortAscending) {
      sourceFiltered
          .sort((a, b) => b["$sortColumn"].compareTo(a["$sortColumn"]));
    } else {
      sourceFiltered
          .sort((a, b) => a["$sortColumn"].compareTo(b["$sortColumn"]));
    }
    var rangeTop = currentPerPage! < sourceFiltered.length
        ? currentPerPage!
        : sourceFiltered.length;
    source = sourceFiltered.getRange(0, rangeTop).toList();
    searchKey = value;
    isLoading = false;
    update();
  }
}
