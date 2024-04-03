import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/categories_controller.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/homeSectionsController.dart';
import 'package:mk_kabbani_admin/pages/categories/layouts/banner_list_categories.dart';
import '../../config.dart';

class HomeSectionsPage extends StatefulWidget {
  @override
  State<HomeSectionsPage> createState() => _HomeSectionsPageState();
}

class _HomeSectionsPageState extends State<HomeSectionsPage> {
  HomeSectionsController homeSectionsCotrl = Get.put(HomeSectionsController());

  @override
  Widget build(BuildContext context) {
    print("From Tik Home sections: ${homeSectionsCotrl.homeSections.length}");
    Size size = MediaQuery.of(context).size;
    return GetBuilder<HomeSectionsController>(builder: (homeSectionsCtrl) {
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
                    homeSectionsCtrl.addBannerDialog();
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
                            "Add section".tr,
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
                        Text("Image EN"),
                        Text("Position"),
                        Text("Image AR"),
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
                      homeSectionsCtrl.updatePrioritiesInFirestore(
                          context, oldIndex, newIndex);
                    });
                  },
                  itemCount: homeSectionsCtrl.homeSections.length,
                  itemBuilder: (context, index) {
                    bool isSwitched = homeSectionsCtrl.homeSections.firstWhere(
                        (element) =>
                            element['collectionId'] ==
                            homeSectionsCtrl.homeSections[index]
                                ['collectionId'])['isShown'];
                    int priority = homeSectionsCtrl.homeSections.firstWhere(
                        (element) =>
                            element['collectionId'] ==
                            homeSectionsCtrl.homeSections[index]
                                ['collectionId'])['priority'];
                    print("home_section_key_${index.toString()}");
                    return Card(
                      key: ValueKey("home_section_key_${index.toString()}"),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 100,
                              child: Text(
                                homeSectionsCtrl.homeSections[index]['title']!,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Spacer(),
                            if (homeSectionsCtrl.homeSections[index]
                                    ['bannerPath'] !=
                                null)
                              Image.network(
                                homeSectionsCtrl.homeSections[index]
                                    ['bannerPath'],
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
                            if (homeSectionsCtrl.homeSections[index]
                                    ['bannerPathAr'] !=
                                null)
                              Image.network(
                                homeSectionsCtrl.homeSections[index]
                                    ['bannerPathAr'],
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
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: OutlinedButton(
                                          onPressed: () {
                                            homeSectionsCtrl.updateBannerDialog(
                                                data: homeSectionsCtrl
                                                    .homeSections[index]);
                                          },
                                          child: const Icon(Icons.edit,
                                              size: Sizes.s18))),
                                  OutlinedButton(
                                      onPressed: () async {
                                        bool isLoginTest = appCtrl.storage
                                            .read(session.isLoginTest);
                                        if (isLoginTest) {
                                          accessDenied(fonts.modification.tr);
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection("homeSections")
                                              .where("collectionId",
                                                  isEqualTo: homeSectionsCtrl
                                                          .homeSections[index]
                                                      ["collectionId"])
                                              .get()
                                              .then((value) {
                                            if (value.docs.isNotEmpty) {
                                              print("DELETE: COL ${homeSectionsCtrl
                                                  .homeSections[index]
                                              ["collectionId"]}");
                                              FirebaseFirestore.instance
                                                  .collection("homeSections")
                                                  .doc(value.docs[0].id)
                                                  .delete();
                                              homeSectionsCtrl.homeSections
                                                  .remove(homeSectionsCtrl
                                                      .homeSections[index]);

                                            }
                                          });
                                          homeSectionsCtrl
                                              .getHomeSections()
                                              .then((val) {
                                            return homeSectionsCtrl.homeSections
                                                .sort((a, b) => a['priority']
                                                    .compareTo(b['priority']));
                                          });
                                          ;
                                          homeSectionsCtrl.update();
                                        }
                                      },
                                      child: const Icon(Icons.delete,
                                          size: Sizes.s18))
                                ]),
                            // CupertinoSwitch(
                            //   value: isSwitched,
                            //   onChanged: (val) async {
                            //     setState(() {
                            //       isSwitched = val;
                            //     });
                            //     homeSectionsCtrl.updateIsShownValue(id: categoryCtrl.homeCategoryList[index].id, val: val);
                            //   },
                            // ),
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
