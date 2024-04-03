import 'dart:async';
import 'dart:html';
import 'dart:io' as io;
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:developer' as log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/add_banner_home_sections.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/update_banner_home_section.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../config.dart';
import 'package:mk_kabbani_admin/shopify/shopify_mixin.dart';
import 'package:mk_kabbani_admin/models/category_model.dart' as cat;



class CategoriesController extends GetxController with ShopifyMixin{
  List<DatatableHeader>? homeSectionsHeaders;
  List<Map<String, dynamic>> switchValues = [];
  late DropzoneViewController? controller1;
  final List<int> perPages = [10, 20, 50, 100];
  int total = 100;
  int? currentPerPage = 10;
  List<bool>? expanded;
  String? searchKey = "id";
  XFile? imageFile;
  int currentPage = 1;
  bool isSearch = false, isUploadSize = false, isAlert = false;
  final List<Map<String, dynamic>> sourceOriginal = [];
  List<Map<String, dynamic>> sourceFiltered = [];
  List<Map<String, dynamic>> source = [];
  List<Map<String, dynamic>> selected = [];
  String imageName = "", imageUrl = "";
  Uint8List webImage = Uint8List(8);
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

  bool sortAscending = true;
  bool isLoading = true;
  final bool showSelect = true;
  io.File? pickImage;
  List homeSections = [];
  List sectionChildren = [];
  var random = Random();
  List<cat.Category> homeCategoryList = [];
  List isShowCats = [];

  Future<void> updatePriorityField() async {
    try {
      // Fetch all documents in the "categories" collection
      final querySnapshot =
      await FirebaseFirestore.instance.collection("categories").get();

      // Iterate through each document and update the "priority" field
      int priority = 1;
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
      in querySnapshot.docs) {
        // Check if the document doesn't already have a "priority" field
        if (!document.data().containsKey("priority")) {
          // Update the document to add the "priority" field with a unique value
          await document.reference.update({'priority': priority});
          priority++;
        }
      }

      print("Update successful");
    } catch (e) {
      print("Error updating priority field: $e");
    }
  }


  Future<void> fetchInitialSwitchValues() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection("categories").orderBy('priority', descending: false).get();

      // Populate switchValues list with documents
      switchValues = querySnapshot.docs.map((doc) {
        return {'id': doc.data()['id'], 'isShown': doc.data()['isShown'] ?? false, 'priority' : doc.data()['priority']};
      }).toList();

      // After fetching values, rebuild the widget to reflect the changes
      update();
      print("TikTik Switch list ${switchValues.length}");
    } catch (e) {
      print("Error fetching initial switch values: $e");
    }
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



  @override
  void onInit() {
    fetchInitialSwitchValues();
    update();
    getData();
    switchValues.sort((a, b) =>
        a['priority'].compareTo(b['priority']));

    // Sort the homeCategoryList based on the sorted switchValues





    super.onInit();
  }

  void updatePrioritiesInFirestore(BuildContext context, int oldIndex, int newIndex) async {
    String categoryId1 = homeCategoryList[oldIndex].id!;
    String categoryId2 = homeCategoryList[newIndex].id!;

    int oldPriority1 = switchValues.firstWhere((element) => element['id'] == categoryId1)['priority'];
    int oldPriority2 = switchValues.firstWhere((element) => element['id'] == categoryId2)['priority'];

    // Swap priorities
    int newPriority1 = oldPriority2;
    int newPriority2 = oldPriority1;



    // Update category 1 in Firestore
    await updateFirestorePriority(categoryId1, newPriority1);

    // Update category 2 in Firestore
    await updateFirestorePriority(categoryId2, newPriority2);

    // Update the priority in the local list for category 1
    switchValues
        .firstWhere((element) => element['id'] == categoryId1)['priority'] =
        newPriority1;

    // Update the priority in the local list for category 2
    switchValues
        .firstWhere((element) => element['id'] == categoryId2)['priority'] =
        newPriority2;

    // Sort the switchValues based on the updated priorities
    switchValues.sort((a, b) =>
        a['priority'].compareTo(b['priority']));

    // Sort the homeCategoryList based on the sorted switchValues
    homeCategoryList.sort((a, b) =>
        switchValues
            .firstWhere((element) => element['id'] == a.id)['priority']
            .compareTo(
            switchValues
                .firstWhere((element) => element['id'] == b.id)['priority']));

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
        .collection("categories")
        .where('id', isEqualTo: categoryId)
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

  updateIsShownValue({required id,required val}) async {
    try {
      // Replace "your_collection" with the name of your Firestore collection
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection("categories")
          .where('id', isEqualTo: id)
          .get();

      // Loop through the documents that match the condition and update the field
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
      in querySnapshot.docs) {
        // Replace "your_field_to_update" with the field you want to update
        await document.reference.update({'isShown': val});
      }

      print("Update successful");
      fetchInitialSwitchValues();
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  Future<void> updatePriorities() async {
    try {
      // Retrieve all documents from the 'categories' collection
      QuerySnapshot<Map<String, dynamic>> collections = await FirebaseFirestore.instance
          .collection('categories')
          .get();

      // Extract and sort the documents based on the current priority
      List<QueryDocumentSnapshot<Map<String, dynamic>>> sortedDocs =
      List.from(collections.docs)
        ..sort((a, b) =>
            (a.data()!['priority'] as int).compareTo(b.data()!['priority'] as int));

      // Use a counter to assign new priorities
      int newPriority = 1;

      // Update each document with the new priority
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in sortedDocs) {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(doc.id)
            .update({'priority': newPriority});

        // Increment the counter for the next document
        newPriority++;
      }

      print('Priorities updated successfully');
    } catch (e) {
      print('Error updating priorities: $e');
    }
  }

  getData()async{
    log.log("Get data started");
    homeCategoryList = await shopifyService.getCategoriesByCursor();

    var collections =  await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('priority', descending: false)
        .get();

    // updatePriorities();



    List<DocumentSnapshot> documentSnapshot = collections.docs;

    List firebaseIds = [];

    for(DocumentSnapshot doc in documentSnapshot){
      Map docData = doc.data() as Map;
      firebaseIds.add(docData['id']);
    }





    for(cat.Category category in homeCategoryList){
      print("Title ${category.name} , id: ${category.id} , banner: ${category.image ?? ""}");
      print("Firebase ids length: ${firebaseIds.toSet().toList().length}");
      if(! firebaseIds.toSet().toList().contains(category.id)){
        FirebaseFirestore.instance.collection("categories").add({
          'id':category.id,
          'isShown' : true,
          'priority' : (homeCategoryList.length),
        });
      }
    }

    homeCategoryList.sort((a, b) =>
        switchValues
            .firstWhere((element) => element['id'] == a.id)['priority']
            .compareTo(
            switchValues
                .firstWhere((element) => element['id'] == b.id)['priority']));

    update();
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
