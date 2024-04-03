import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/home_category_list_controller.dart';
import '../../config.dart';

class HomeCatListScreen extends StatefulWidget {
  @override
  State<HomeCatListScreen> createState() => _HomeCatListScreenState();
}

class _HomeCatListScreenState extends State<HomeCatListScreen> {
  final homeCatListCtrl = Get.put(HomeCatListController());

  @override
  Widget build(BuildContext context) {
    print("From Tik CAt: ${homeCatListCtrl.homeCategoryList.length}");
    Size size = MediaQuery.of(context).size;
    return GetBuilder<HomeCatListController>(builder: (homeCatListCtrl) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                  onPressed: () {
                    homeCatListCtrl.addBannerDialog();
                  },
                  child: Container(
                    width: 150,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: appCtrl.appTheme.primary,
                          ),
                          Text(
                            "Add category".tr,
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  )),
            ),
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
                        Text("Image Ar"),
                        Row(
                          children: [
                            Text("Actions"),
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
                      // Swap priorities in Firestore
                      homeCatListCtrl.updatePrioritiesInFirestore(
                          context, oldIndex, newIndex);
                    });
                  },
                  itemCount: homeCatListCtrl.homeCategoryView.length,
                  itemBuilder: (context, index) {
                    // bool isSwitched = categoryCtrl.switchValues
                    //     .firstWhere((element) => element['id'] == categoryCtrl.homeCategoryList[index].id)['isShown'];

                    print("ID TIK TIK: ${homeCatListCtrl.firebaseCats
                        .firstWhere((element) =>
                    element['id'] ==
                        homeCatListCtrl
                            .homeCategoryView[index].id)['id']
                        }");
                    int priority = homeCatListCtrl.firebaseCats.firstWhere(
                            (element) =>
                                element['id'] ==
                                homeCatListCtrl
                                    .homeCategoryView[index].id)['priority'] ??
                        0;
                    String bannerPath = homeCatListCtrl.firebaseCats.firstWhere(
                        (element) =>
                            element['id'] ==
                            homeCatListCtrl
                                .homeCategoryView[index].id)['bannerPath'];
                    String bannerPathAr = homeCatListCtrl.firebaseCats
                        .firstWhere((element) =>
                            element['id'] ==
                            homeCatListCtrl
                                .homeCategoryView[index].id)['bannerPathAr'];

                    return Card(
                      key: ValueKey("home_cat_key_${index.toString()}"),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 100,
                              child: Text(
                                homeCatListCtrl.homeCategoryView[index].name!,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Spacer(),
                            if (bannerPath != null)
                              Image.network(
                                bannerPath,
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
                            if (bannerPathAr != null)
                              Image.network(
                                bannerPathAr,
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
                            // CupertinoSwitch(
                            //   value: isSwitched,
                            //   onChanged: (val) async {
                            //     setState(() {
                            //       isSwitched = val;
                            //     });
                            //     categoryCtrl.updateIsShownValue(id: categoryCtrl.homeCategoryList[index].id, val: val);
                            //   },
                            // ),
                            Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: OutlinedButton(
                                          onPressed: () {
                                            homeCatListCtrl.updateBannerDialog(
                                                data: homeCatListCtrl
                                                    .firebaseCats.firstWhere((element) => element['id'] == homeCatListCtrl.homeCategoryView[index].id)
                                            ).then((){
                                              setState(() {});
                                            });
                                          },
                                          child: const Icon(Icons.edit,
                                              size: Sizes.s18),),),
                                  OutlinedButton(
                                      onPressed: () async{
                    await homeCatListCtrl.deleteCategory(
                    homeCatListCtrl
                        .homeCategoryView[index].id!,
                    );
                    },
                                      child: const Icon(Icons.delete,
                                          size: Sizes.s18))
                                ]),
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
