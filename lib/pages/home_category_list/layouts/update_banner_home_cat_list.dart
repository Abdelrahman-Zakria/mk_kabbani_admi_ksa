import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/homeSectionsController.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/home_category_list_controller.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/banner_class_home_sections.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/banner_image_layout_ar_home_section.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/banner_image_layout_home_sections.dart';
import 'package:mk_kabbani_admin/models/category_model.dart' as cat;
import 'package:mk_kabbani_admin/pages/home_category_list/layouts/banner_image_layout_ar_home_cat_list.dart';
import 'package:mk_kabbani_admin/pages/home_category_list/layouts/banner_image_layout_home_cat_list.dart';

import '../../../config.dart';

class UpdateSectionCatList extends StatelessWidget {

  String? currentId;

  UpdateSectionCatList({Key? key,required this.currentId});



  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return GetBuilder<HomeCatListController>(builder: (bannerCtrl) {
            return Stack(alignment: Alignment.topCenter, children: [
              AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: SingleChildScrollView(
                    child: Container(
                        decoration: BoxDecoration(
                            color: appCtrl.appTheme.whiteColor,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: appCtrl.isTheme ?  1 :0,
                                  spreadRadius: appCtrl.isTheme ?  1 :0,
                                  color: appCtrl.appTheme.blackColor
                              )
                            ]),
                        width: Sizes.s500,
                        child:
                        Stack(alignment: Alignment.topRight, children: <Widget>[
                          Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                            SectionCommonClass().addBannerTitle(),
                            Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 80),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black,width: 1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: DropdownButton(
                                                underline: SizedBox.shrink(),
                                                hint: Text("Choose collection"),
                                                items: bannerCtrl.homeCategoryList.map((cat.Category collection) {
                                                  return DropdownMenuItem<String>(
                                                    value: collection.id,

                                                    child: Text(collection.name!),
                                                  );
                                                }).toList(),
                                                onChanged: (val){
                                                  print("Val changed $val");
                                                  // bannerCtrl.changeNewSectionId(val);
                                                  setState((){
                                                    bannerCtrl.txtTitle.text = bannerCtrl.homeCategoryList.where((element) => element.id == val).first.name!;
                                                    bannerCtrl.txtTitleAr.text = bannerCtrl.homeCategoryList.where((element) => element.id == val).first.name!;

                                                    bannerCtrl.txtId.text = bannerCtrl.homeCategoryList.where((element) => element.id == val).first.id!;
                                                  });

                                                }),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 40,),
                                      CommonTextBox(
                                          hinText: fonts.name.tr,
                                          controller: bannerCtrl.txtTitle),
                                      const VSpace(Sizes.s15),
                                      CommonTextBox(
                                          hinText: fonts.nameAr.tr,
                                          controller: bannerCtrl.txtTitleAr),
                                      const VSpace(Sizes.s15),
                                      CommonTextBox(
                                          hinText: fonts.collectionId.tr,
                                          controller: bannerCtrl.txtId),
                                      const VSpace(Sizes.s15),

                                      // Container(
                                      //   width: MediaQuery.of(context).size.width,
                                      //   child: Row(
                                      //     mainAxisAlignment: MainAxisAlignment.center,
                                      //     children: [
                                      //       Text("Show in app".tr),
                                      //       SizedBox(width: 20,),
                                      //       StatefulBuilder(
                                      //           builder: (context,setState) {
                                      //             return CupertinoSwitch(
                                      //                 value: bannerCtrl.isSectionShown!.value, onChanged: (val)async{
                                      //               setState((){
                                      //                 bannerCtrl.isSectionShown!.value = !bannerCtrl.isSectionShown!.value;
                                      //               });
                                      //               await bannerCtrl.updateSectionStatus(bannerCtrl.txtId.text,val);
                                      //               print(bannerCtrl.isSectionShown!.value);
                                      //             });
                                      //           }
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // const VSpace(Sizes.s15),
                                      //
                                      // bannerCtrl.sectionChildren.length > 0 ? Container(
                                      //     width: MediaQuery.of(context).size.width,
                                      //     child: Row(
                                      //       children: [
                                      //         Text("Sub collections".tr,textAlign: TextAlign.center,),
                                      //       ],
                                      //     )
                                      // ) : SizedBox.shrink(),
                                      // // const BannerProductCollection()
                                      // bannerCtrl.sectionChildren.length > 0 ? Container(
                                      //   height: 150,
                                      //   child: ListView.builder(
                                      //       itemCount: bannerCtrl.sectionChildren.length,
                                      //       itemBuilder: (context, index) {
                                      //         print("From edit:"+bannerCtrl.sectionChildren[index].toString());
                                      //         TextEditingController txtBanner = TextEditingController();
                                      //         //txtBanner.text = bannerCtrl.sectionChildren[index]['bannerPath'];
                                      //         return Padding(
                                      //           padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 4),
                                      //           child: Container(
                                      //             decoration: BoxDecoration(
                                      //               color: Colors.grey[400],
                                      //               borderRadius: BorderRadius.circular(15),
                                      //             ),
                                      //             child: Padding(
                                      //               padding: const EdgeInsets.all(10.0),
                                      //               child: Row(
                                      //                 children: [
                                      //                   Container(
                                      //                     width: 200,
                                      //                     child: Column(
                                      //                       crossAxisAlignment: CrossAxisAlignment.start,
                                      //                       children: [
                                      //                         Text(
                                      //                           bannerCtrl.homeCategoryList.where((element) =>
                                      //                           element.id == bannerCtrl.sectionChildren[index]['id']).toList()[0]
                                      //                               .name!,
                                      //                           overflow: TextOverflow.ellipsis,
                                      //                         ),
                                      //                         SizedBox(
                                      //                           height: 10,
                                      //                         ),
                                      //                         Text(
                                      //                           bannerCtrl.sectionChildren[index]['bannerPath'],
                                      //                           overflow: TextOverflow.ellipsis,
                                      //                         ),
                                      //
                                      //                       ],
                                      //                     ),
                                      //                   ),
                                      //                   Expanded(child: SizedBox()),
                                      //                   IconButton(onPressed: (){
                                      //                     showDialog(context: context, builder: (context) {
                                      //                       TextEditingController idCtrl = TextEditingController();
                                      //                       TextEditingController editBanner = TextEditingController();
                                      //
                                      //
                                      //                       print("ID CTRL"+bannerCtrl.addNewId.text);
                                      //                       return AlertDialog(
                                      //                         content: Container(
                                      //                           decoration: BoxDecoration(
                                      //                               color: appCtrl.appTheme.whiteColor,
                                      //                               boxShadow: [
                                      //                                 BoxShadow(
                                      //                                     blurRadius: appCtrl.isTheme ?  1 :0,
                                      //                                     spreadRadius: appCtrl.isTheme ?  1 :0,
                                      //                                     color: appCtrl.appTheme.blackColor
                                      //                                 )
                                      //                               ]),
                                      //                           width: Sizes.s500,
                                      //                           child: Padding(
                                      //                             padding: const EdgeInsets.all(20.0),
                                      //                             child: Stack(
                                      //                               children: [
                                      //                                 Column(
                                      //                                   crossAxisAlignment: CrossAxisAlignment.center,
                                      //                                   children: [
                                      //                                     Padding(
                                      //                                       padding: const EdgeInsets.only(top: 15.0),
                                      //                                       child: Text("Edit sub collection".tr,style: AppCss.nunitoblack20
                                      //                                           .textColor(appCtrl.appTheme.blackColor)),
                                      //                                     ),
                                      //                                     SizedBox(height: 100,),
                                      //                                     Text("Sub collection id: " + bannerCtrl.sectionChildren[index]['id']),
                                      //                                     // SizedBox(height: 16,),
                                      //                                     // CommonTextBox(
                                      //                                     //   controller: bannerCtrl.addNewId,
                                      //                                     //   hinText: "ID",
                                      //                                     // ),
                                      //                                     SizedBox(height: 16,),
                                      //                                     CommonTextBox(
                                      //                                       controller: editBanner,
                                      //                                       hinText: "Banner path",
                                      //                                     ),
                                      //
                                      //                                     Expanded(child: SizedBox()),
                                      //
                                      //                                     CommonButton(title: "Update".tr,color: appCtrl.appTheme.primary , onTap: ()async{
                                      //                                       // await bannerCtrl.addMapToChildren(bannerCtrl.txtId.text, {
                                      //                                       //   "id" : bannerCtrl.addNewId.text,
                                      //                                       //   "bannerPath" : bannerCtrl.addNewBanner.text,
                                      //                                       // }).then((value) => Navigator.of(context).pop());
                                      //                                       await bannerCtrl.updateChildBannerPath(bannerCtrl.txtId.text, bannerCtrl.sectionChildren[index]['id'], editBanner.text);
                                      //                                     }),
                                      //                                   ],
                                      //                                 ),
                                      //                                 Positioned(
                                      //                                     right: 0.0,
                                      //                                     top: 0.0,
                                      //                                     child: InkResponse(
                                      //                                         onTap: () => Navigator.of(context).pop(),
                                      //                                         child: CircleAvatar(
                                      //                                             radius: 12,
                                      //                                             backgroundColor: appCtrl.appTheme.primary,
                                      //                                             child: Icon(Icons.close,
                                      //                                                 size: 18, color: appCtrl.appTheme.white)))),
                                      //                               ],
                                      //                             ),
                                      //                           ),
                                      //                         ),
                                      //                       );
                                      //                     }
                                      //
                                      //                     );
                                      //                   }, icon: Icon(Icons.edit)),
                                      //                   IconButton(onPressed: (){
                                      //                     bannerCtrl.deleteChildAndShowConfirmation(context,bannerCtrl.txtId.text, bannerCtrl.sectionChildren[index]['id']);
                                      //                   }, icon: Icon(Icons.delete)),
                                      //
                                      //                 ],
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         );
                                      //       }
                                      //   ),
                                      // ) : SizedBox.shrink(),
                                      // const VSpace(Sizes.s15),
                                      // GestureDetector(
                                      //   onTap: (){
                                      //     showDialog(context: context, builder: (context) {
                                      //       print("ID CTRL"+bannerCtrl.addNewId.text);
                                      //       return AlertDialog(
                                      //         content: Container(
                                      //           decoration: BoxDecoration(
                                      //               color: appCtrl.appTheme.whiteColor,
                                      //               boxShadow: [
                                      //                 BoxShadow(
                                      //                     blurRadius: appCtrl.isTheme ?  1 :0,
                                      //                     spreadRadius: appCtrl.isTheme ?  1 :0,
                                      //                     color: appCtrl.appTheme.blackColor
                                      //                 )
                                      //               ]),
                                      //           width: Sizes.s500,
                                      //           child: Padding(
                                      //             padding: const EdgeInsets.all(20.0),
                                      //             child: Stack(
                                      //               children: [
                                      //                 Column(
                                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                                      //                   children: [
                                      //                     Padding(
                                      //                       padding: const EdgeInsets.only(top: 15.0),
                                      //                       child: Text("Add new sub collection".tr,style: AppCss.nunitoblack20
                                      //                           .textColor(appCtrl.appTheme.blackColor)),
                                      //                     ),
                                      //                     Padding(
                                      //                       padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      //                       child: Text("Choose new sub collection from the collections below" , ),
                                      //                     ),
                                      //                     DropdownButton(
                                      //                         items: bannerCtrl.homeCategoryList.map((cat.Category collection) {
                                      //                           return DropdownMenuItem<String>(
                                      //                             value: collection.id,
                                      //                             child: Text(collection.name!),
                                      //                           );
                                      //                         }).toList(),
                                      //                         onChanged: (val){
                                      //                           print("Val changed $val");
                                      //                           bannerCtrl.changeNewSectionId(val);
                                      //                         }),
                                      //                     SizedBox(height: 100,),
                                      //                     CommonTextBox(
                                      //                       controller: bannerCtrl.addNewTitle,
                                      //                       hinText: "Title",
                                      //                     ),
                                      //                     // SizedBox(height: 16,),
                                      //                     // CommonTextBox(
                                      //                     //   controller: bannerCtrl.addNewId,
                                      //                     //   hinText: "ID",
                                      //                     // ),
                                      //                     SizedBox(height: 16,),
                                      //                     CommonTextBox(
                                      //                       controller: bannerCtrl.addNewBanner,
                                      //                       hinText: "Banner path",
                                      //                     ),
                                      //
                                      //                     Expanded(child: SizedBox()),
                                      //
                                      //                     CommonButton(title: "Update".tr,color: appCtrl.appTheme.primary , onTap: ()async{
                                      //                       await bannerCtrl.addMapToChildren(bannerCtrl.txtId.text, {
                                      //                         "id" : bannerCtrl.addNewId.text,
                                      //                         "bannerPath" : bannerCtrl.addNewBanner.text,
                                      //                       }).then((value) => Navigator.of(context).pop());
                                      //                     }),
                                      //                   ],
                                      //                 ),
                                      //                 Positioned(
                                      //                     right: 0.0,
                                      //                     top: 0.0,
                                      //                     child: InkResponse(
                                      //                         onTap: () => Navigator.of(context).pop(),
                                      //                         child: CircleAvatar(
                                      //                             radius: 12,
                                      //                             backgroundColor: appCtrl.appTheme.primary,
                                      //                             child: Icon(Icons.close,
                                      //                                 size: 18, color: appCtrl.appTheme.white)))),
                                      //               ],
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       );
                                      //     }
                                      //
                                      //     );
                                      //   },
                                      //   child: Align(
                                      //     alignment: Alignment.center,
                                      //     child: Container(
                                      //       width: 200,
                                      //       decoration: BoxDecoration(
                                      //         borderRadius: BorderRadius.circular(15),
                                      //         border: Border.all(color: Colors.black),
                                      //       ),
                                      //       child: Row(
                                      //         mainAxisSize: MainAxisSize.min,
                                      //         mainAxisAlignment: MainAxisAlignment.center,
                                      //         children: [
                                      //           Text("Add new sub collection".tr),
                                      //           Icon(Icons.add),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                      // )

                                    ])),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("EN : "),
                                Text("Recommended image size: 329 * 161".tr),

                              ],
                            ),
                            VSpace(Sizes.s2),
                            const CatListImageLayout(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("AR : "),
                                Text("Recommended image size: 329 * 161".tr),
                              ],
                            ),
                            VSpace(Sizes.s2),

                            const CatListImageLayoutAr(),
                            const VSpace(Sizes.s10),
                            if (bannerCtrl.isUploadSize)
                              Column(children: [
                                const VSpace(Sizes.s5),
                                Text(fonts.imageError.tr,
                                    style: AppCss.nunitoMedium12
                                        .textColor(appCtrl.appTheme.redColor))
                              ]),
                            const VSpace(Sizes.s25),
                            CommonButton(
                                icon: bannerCtrl.isLoading
                                    ? CircularProgressIndicator(
                                    color: appCtrl.appTheme.white)
                                    .paddingSymmetric(vertical: Insets.i10)
                                    : Container(),
                                title: bannerCtrl.isLoading
                                    ? "loading.."
                                    : bannerCtrl.bannerId != ""
                                    ? "Update"
                                    : "Update",
                                onTap: () {
                                  // bannerCtrl.uploadFile();
                                  // bannerCtrl.uploadFileAr();
                                  // bannerCtrl.addNewMainCategoryItem(bannerCtrl.txtId.text, bannerCtrl.txtId.text, bannerCtrl.imageUrl, bannerCtrl.imageUrlAr ?? bannerCtrl.imageUrl);
                                  bannerCtrl.uploadFileUpdate(context,currentId,bannerCtrl.txtId.text);
                                },
                                style: AppCss.nunitoblack14
                                    .textColor(appCtrl.appTheme.white)),
                            const VSpace(Sizes.s15)
                          ]),
                          Positioned(
                              right: 15.0,
                              top: 15.0,
                              child: InkResponse(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: appCtrl.appTheme.primary,
                                      child: Icon(Icons.close,
                                          size: 18, color: appCtrl.appTheme.white))))
                        ])),
                  )),
              CustomSnackBar(isAlert: bannerCtrl.isAlert)
            ]);
          });
        });
  }
}
