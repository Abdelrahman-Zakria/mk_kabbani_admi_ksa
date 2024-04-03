import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/categories_controller.dart';
import 'package:mk_kabbani_admin/pages/categories/layouts/banner_list_categories.dart';
import '../../config.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final categoryCtrl = Get.put(CategoriesController());

  @override
  Widget build(BuildContext context) {
    print("From Tik CAt: ${categoryCtrl.homeCategoryList.length}");
    Size size = MediaQuery.of(context).size;
    return GetBuilder<CategoriesController>(builder: (_) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 80,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Name"),
                        Text("Image"),
                        Text("Position"),
                        Row(
                          children: [
                            Text("Show"),
                            Space(40, 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(Insets.i10),
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(maxHeight: 700),
              child: Card(
                elevation: 3,
                shadowColor: appCtrl.appTheme.blackColor,
                color: appCtrl.appTheme.whiteColor,
                clipBehavior: Clip.none,
                child: ReorderableListView.builder(
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      categoryCtrl.updatePrioritiesInFirestore(context, oldIndex, newIndex);
                    });
                  },
                  itemCount: categoryCtrl.homeCategoryList.length,
                  itemBuilder: (context, index) {

                    bool isSwitched = categoryCtrl.switchValues
                        .firstWhere((element) => element['id'] == categoryCtrl.homeCategoryList[index].id)['isShown'];
                    int priority = categoryCtrl.switchValues
                        .firstWhere((element) => element['id'] == categoryCtrl.homeCategoryList[index].id)['priority'];
                    return Card(
                      key: ValueKey(categoryCtrl.homeCategoryList[index].id),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 100,
                              child: Text(
                                categoryCtrl.homeCategoryList[index].name!,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Spacer(),
                            if (categoryCtrl.homeCategoryList[index].image != null)
                              Image.network(
                                categoryCtrl.homeCategoryList[index].image!,
                                width: Sizes.s200,
                                height: Sizes.s100,
                                fit: BoxFit.cover,
                              )
                            else
                              Image.network(
                                "https://trello-attachments.s3.amazonaws.com/5d64f19a7cd71013a9a418cf/640x480/1dfc14f78ab0dbb3de0e62ae7ebded0c/placeholder.jpg",
                                width: Sizes.s200,
                                height: Sizes.s100,
                                fit: BoxFit.cover,
                              ),
                            Spacer(),
                            Text(priority.toString()),
                            Spacer(),
                            CupertinoSwitch(
                              value: isSwitched,
                              onChanged: (val) async {
                                setState(() {
                                  isSwitched = val;
                                });
                                categoryCtrl.updateIsShownValue(id: categoryCtrl.homeCategoryList[index].id, val: val);
                              },
                            ),
                            Space(30, 0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

 
}
