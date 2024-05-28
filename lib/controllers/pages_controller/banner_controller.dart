import 'dart:async';
import 'dart:html';
import 'dart:io' as io;
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:developer' as log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../config.dart';

class BannerController extends GetxController {
  List<DatatableHeader>? headers;

  late DropzoneViewController? controller1;

  late DropzoneViewController? controller2;

  final List<int> perPages = [10, 20, 50, 100];
  int total = 100;
  int? currentPerPage = 10;
  List<bool>? expanded;
  String? searchKey = "id";
  XFile? imageFile;
  XFile? imageFileAr;

  int currentPage = 1;
  bool isSearch = false, isUploadSize = false, isAlert = false;
  final List<Map<String, dynamic>> sourceOriginal = [];
  List<Map<String, dynamic>> sourceFiltered = [];
  List<Map<String, dynamic>> source = [];
  List<Map<String, dynamic>> selected = [];
  String imageName = "", imageUrl = "";

  String imageNameAr = "", imageUrlAr = "";

  Uint8List webImage = Uint8List(8);
  Uint8List webImageAr = Uint8List(8);
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtId = TextEditingController();

  // ignore: unused_field
  final String selectableKey = "id";
  String idType = "", bannerId = "";
  int bannerPriority = 0;
  String? sortColumn;
  Uint8List uploadWebImage = Uint8List(8);
  Uint8List uploadWebImageAr = Uint8List(8);


  bool sortAscending = true;
  bool isLoading = true;
  final bool showSelect = true;
  io.File? pickImage;
  io.File? pickImageAr;
  List banner = [];
  List homeSections = [];
  var random = Random();

  List<Map<String, dynamic>> _generateData() {

    List source = banner;
    print("Source length _generateData: ${source.length}");

    List<Map<String, dynamic>> temps = [];
    var i = 1;
    if (kDebugMode) {
      print(i);
    }
    // ignore: unused_local_variable
    for (var data in source) {

      temps.add({
        "id": data["bannerId"],
        "image": data["image"],
        "name": data["title"],
        "imageAr" : data['imageAr'],
        "isActive": data["isActive"],
        "priority" : data['priority'],
        "action": i,
        "isProduct": data["isProduct"],
        "productCollectionId": data["productCollectionId"],
        "bannerId": data["bannerId"]
      });
      i++;
    }
    return temps;
  }

  List getData() {
    print("GET BANNERS STARTED");
    banner = [];
    FirebaseFirestore.instance
        .collection(collectionName.banner)
    .orderBy('priority')
        .get()
        .then((value) {
      value.docs.asMap().entries.forEach((element) {
        banner.add(element.value.data());
        print("Banner Added: ${element.value.data()['']}");
      });
    });

    update();
    return banner;
  }

  List getHomeSections(){
    homeSections = [];
    FirebaseFirestore.instance
        .collection("homeSections")
        .get()
        .then((value) {
      value.docs.asMap().entries.forEach((element) {
        homeSections.add(element.value.data());
      });
    });

    update();
    return homeSections;
  }

  initializeData() async {
    await getData();

    await mockPullData();

    source.isNotEmpty ?
        {
          print("BANNER LENGTH ${source.length}"),
          source.forEach((element) {
       print("Banner ID from source: ${element['bannerId']}");
    }),
    source.sort((a, b) =>
        source
            .firstWhere((element) => element['bannerId'] == a['bannerId'])['priority']
            .compareTo(
            source
                .firstWhere((element) => element['bannerId'] == b['bannerId'])['priority'])) }: mockPullData();

    update();
  }

  //add banner
  saveBanner() async {
    isLoading = true;
    update();

    try {
      if (bannerId == "") {
        int id = DateTime.now().millisecondsSinceEpoch;
        await FirebaseFirestore.instance.collection(collectionName.banner).add({
          "productCollectionId": txtId.text,
          "image": imageUrl,
          "imageAr" : imageUrlAr,
          "bannerId": id,
          "priority" : (banner.length - 1),
          "isProduct": txtId.text.isEmpty
              ? false
              : idType == "product"
                  ? true
                  : false,
          "title": txtTitle.text,
          "isActive": true
        }).then((value) {
          isLoading = false;
          update();
          Get.back();
          txtTitle.text = "";
          txtId.text = "";
          idType = "";
          imageFile =null;
          imageFileAr =null;

          webImage = Uint8List(8);
          imageUrl ="";
          imageUrlAr = "";
          initializeData();
        });
      } else {

        await FirebaseFirestore.instance
            .collection(collectionName.banner)
            .get()
            .then((value) {
          value.docs.asMap().entries.forEach((element) {


            if (bannerId.toString() ==
                element.value.data()["bannerId"].toString()) {

              FirebaseFirestore.instance
                  .collection(collectionName.banner)
                  .doc(element.value.id)
                  .update({
                "productCollectionId": txtId.text,
                "image": imageUrl,
                "imageAr" : imageUrlAr,
                "bannerId": bannerId,
                "priority" : bannerPriority,
                "isProduct": element.value.data()["isProduct"],
                "title": txtTitle.text,
                "isActive": true,
              }).then((value) {
                txtTitle.text = "";
                txtId.text = "";
                idType = "";
                imageFile =null;
                imageFileAr =null;
                webImage = Uint8List(8);
                imageUrl ="";
              });
            }
          });
        });
      }
    } catch (e) {
      log.log("save error: $e");
    } finally {
      isLoading = false;
      Get.back();
      initialSetUi();
      initializeData();
      update();
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
      source = sourceFiltered;
      print("Source length mockPullData : ${source.length}");

      // if (sourceFiltered.length > 5) {
      //   source = sourceFiltered.getRange(0, currentPerPage!).toList();
      //
      // } else {
      //   source = sourceFiltered;
      // }

      isLoading = false;

      update();
    });
  }

  //flutter build web --web-renderer html --release

//add banner dialog
  addBannerDialog({data}) async {
    if (data != null) {
      txtTitle.text = data["name"];
      txtId.text = data["productCollectionId"].toString();
      idType = data["isProduct"] == true ? "product" : "collection";
      imageUrl = data["image"];
      imageUrlAr = data['imageAr'];
      bannerId = data["bannerId"].toString();
      update();
    } else {
      txtTitle.text = "";
      txtId.text = "";
      idType = "";
      imageUrl = "";
      bannerId = "";
      imageUrlAr = "";
      update();
    }

    log.log("bannerId : $bannerId");

    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return const AddBanner();
          });
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
      print("Source length resetData : ${source.length}");

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
      print("Source length filterData: ${source.length}");

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




  initialSetUi() async {
    String imageUrl = "image_url";
    // https://github.com/flutter/flutter/issues/41563
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      imageUrl,
      (int _) => ImageElement()..src = imageUrl,
    );
    getData();
    getHomeSections();
    headers = [
      DatatableHeader(
          text: "ID",
          value: "productCollectionId",
          show: true,
          sortable: true,
          flex: 1,
          textAlign: TextAlign.center),
      DatatableHeader(
          text: "Image EN",
          value: "image",
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
          value: "name",
          show: true,
          sortable: true,
          textAlign: TextAlign.center),
      DatatableHeader(
          text: "Image AR",
          value: "imageAr",
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
                            addBannerDialog(data: row);
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
                              .collection(collectionName.banner)
                              .where("bannerId", isEqualTo: row["id"])
                              .get()
                              .then((value) {
                            if (value.docs.isNotEmpty) {
                              FirebaseFirestore.instance
                                  .collection(collectionName.banner)
                                  .doc(value.docs[0].id)
                                  .delete();
                            }
                          });
                          initialSetUi();
                          initializeData();
                        }
                      },
                      child: const Icon(Icons.delete, size: Sizes.s18))
                ]);
          },
          textAlign: TextAlign.center),
    ];

    isLoading = false;
    update();
  }


  Widget buildActions(row){
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 16),
              child: OutlinedButton(
                  onPressed: () {
                    addBannerDialog(data: row);
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
                      .collection(collectionName.banner)
                      .where("bannerId", isEqualTo: row["id"])
                      .get()
                      .then((value) {
                    if (value.docs.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection(collectionName.banner)
                          .doc(value.docs[0].id)
                          .delete();
                    }
                  });
                  initialSetUi();
                  initializeData();
                }
              },
              child: const Icon(Icons.delete, size: Sizes.s18))
        ]);
  }

  Future<void> updateFirestorePriority(String categoryId, int newPriority) async {
    print("Updating Firestore for categoryId: $categoryId, newPriority: $newPriority");

    // Use .where('id', isEqualTo: categoryId) for the query
    await FirebaseFirestore.instance
        .collection("banner")
        .where('bannerId', isEqualTo: categoryId)
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


  void updatePrioritiesInFirestore(BuildContext context, int oldIndex, int newIndex) async {
    String categoryId1 = source[oldIndex]['bannerId'];
    String categoryId2 = source[newIndex]['bannerId'];

    int oldPriority1 = source.firstWhere((element) => element['bannerId'] == categoryId1)['priority'];
    int oldPriority2 = source.firstWhere((element) => element['bannerId'] == categoryId2)['priority'];

    // Swap priorities
    int newPriority1 = oldPriority2;
    int newPriority2 = oldPriority1;



    // Update category 1 in Firestore
    await updateFirestorePriority(categoryId1, newPriority1);

    // Update category 2 in Firestore
    await updateFirestorePriority(categoryId2, newPriority2);

    // Update the priority in the local list for category 1

    await initializeData();

    // await getData();
    // // initialSetUi();
    //
    // source.sort((a, b) =>
    //     source
    //         .firstWhere((element) => element['bannerId'] == a['bannerId'])['priority']
    //         .compareTo(
    //         source
    //             .firstWhere((element) => element['bannerId'] == b['bannerId'])['priority']));

    // Trigger a rebuild of the UI
    update();

    // Delay to show CircularProgressIndicator for a short duration

    // Pop the dialog
  }


  @override
  void onInit() {
    // TODO: implement onInit
    initialSetUi();
    update();
    initializeData();
    source.sort((a, b) =>
        a['priority'].compareTo(b['priority']));
    super.onInit();
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

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    bool isLoginTest = appCtrl.storage.read(session.isLoginTest);
    if (isLoginTest) {
      accessDenied(fonts.modification.tr);
    } else {
      isLoading = true;
      if (pickImage != null && pickImageAr != null) {
        update();
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        String fileNameAr = DateTime.now().millisecondsSinceEpoch.toString() + "AR";
        Reference referenceAr = FirebaseStorage.instance.ref().child(fileNameAr);
        Reference reference = FirebaseStorage.instance.ref().child(fileName);
        log.log("reference : $webImage");
        UploadTask? uploadTask;
        uploadTask = reference.putData(webImage);

        UploadTask uploadTaskAr;
        uploadTaskAr = referenceAr.putData(webImageAr);

        uploadTask.then((res) async {
          log.log("res : $res");
          res.ref.getDownloadURL().then((downloadUrl) async {
            imageUrl = downloadUrl;
            log.log("imageUrl : $imageUrl");
            update();
            uploadTaskAr.then((resAr)async{
              resAr.ref.getDownloadURL().then((downloadUrlAr)async{
                imageUrlAr = downloadUrlAr;
                log.log("imageUrlAr : $imageUrlAr");
                update();
                await Future.delayed(Durationss.s3);
                saveBanner();
              });
            });
          }, onError: (err) {
            update();
          });
        });
      } else {
        saveBanner();
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
        log.log("uploadWebImageAr : $uploadWebImageAr");
        Image image1 = Image.memory(uploadWebImageAr);

        ImageInfo info = await getImageInfo(image1);

        if (info.image.width > 300 && info.image.height > 50) {
          webImageAr = uploadWebImageAr;
          pickImageAr = io.File("b");
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
      log.log("imageFileAr : $imageFileAr");

      if (imageFileAr!.name.contains("png") ||
          imageFileAr!.name.contains("jpg") ||
          imageFileAr!.name.contains("jpeg")) {
        var image = await imageFileAr!.readAsBytes();
        uploadWebImageAr = image;

        Image image2 = Image.memory(uploadWebImageAr);
        log.log("image2 : $image2");
        ImageInfo info = await getImageInfo(image2);

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

// UPLOAD SELECTED IMAGE TO FIREBASE
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
        log.log("reference : $webImage");
        UploadTask? uploadTask;
        uploadTask = reference.putData(webImageAr);

        uploadTask.then((res) async {
          log.log("res : $res");
          res.ref.getDownloadURL().then((downloadUrl) async {
            imageUrlAr = downloadUrl;
            log.log("imageUrl : $imageUrlAr");
            update();
            await Future.delayed(Durationss.s3);

            saveBanner();
          }, onError: (err) {
            update();
          });
        });
      } else {
        saveBanner();
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
    print("Source length: ${source.length}");
    searchKey = value;
    isLoading = false;
    update();
  }
}
