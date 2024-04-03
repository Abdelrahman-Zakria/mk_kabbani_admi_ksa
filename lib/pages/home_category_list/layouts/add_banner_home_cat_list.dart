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

class AddSectionCatList extends StatelessWidget {

  const AddSectionCatList({Key? key, childrenList});


  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return GetBuilder<HomeCatListController>(builder: (bannerCtrl) {
            return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                        color: appCtrl.appTheme.whiteColor,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: appCtrl.isTheme ? 1 : 0,
                              spreadRadius: appCtrl.isTheme ? 1 : 0,
                              color: appCtrl.appTheme.blackColor
                          )
                        ]),
                    width: Sizes.s500,
                    child: Stack(alignment: Alignment.topRight, children: <Widget>[
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      SectionCommonClass().addBannerTitle(),
                      Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 80),
                                  child: Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: DropdownButton(
                                          underline: SizedBox.shrink(),
                                          hint: Text("Choose collection"),
                                          items: bannerCtrl.homeCategoryList
                                              .map((cat.Category collection) {
                                            return DropdownMenuItem<String>(
                                              value: collection.id,

                                              child: Text(collection.name!),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            print("Val changed $val");
                                            // bannerCtrl.changeNewSectionId(val);
                                            setState(() {
                                              bannerCtrl.txtTitle.text =
                                              bannerCtrl.homeCategoryList
                                                  .where((element) =>
                                              element.id == val)
                                                  .first
                                                  .name!;
                                              bannerCtrl.txtTitleAr.text =
                                              bannerCtrl.homeCategoryList
                                                  .where((element) =>
                                              element.id == val)
                                                  .first
                                                  .name!;

                                              bannerCtrl.txtId.text =
                                              bannerCtrl.homeCategoryList
                                                  .where((element) =>
                                              element.id == val)
                                                  .first
                                                  .id!;
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


                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text("EN : "),
                                    Text("Recommended image size: 329 * 161"
                                        .tr),

                                  ],
                                ),
                                VSpace(Sizes.s2),
                                const CatListImageLayout(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text("AR : "),
                                    Text("Recommended image size: 329 * 161"
                                        .tr),
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
                                            .textColor(
                                            appCtrl.appTheme.redColor))
                                  ]),
                                const VSpace(Sizes.s25),
                                CommonButton(
                                    icon: bannerCtrl.isLoading
                                        ? CircularProgressIndicator(
                                        color: appCtrl.appTheme.white)
                                        .paddingSymmetric(
                                        vertical: Insets.i10)
                                        : Container(),
                                    title: bannerCtrl.isLoading
                                        ? "loading.."
                                        : bannerCtrl.bannerId != ""
                                        ? "Update"
                                        : fonts.submit.tr,
                                    onTap: () {
                                      bannerCtrl.uploadFile();
                                     // bannerCtrl.uploadFileAr();
                                      //bannerCtrl.addNewMainCategoryItem(bannerCtrl.txtId.text, bannerCtrl.txtId.text, bannerCtrl.imageUrl, bannerCtrl.imageUrlAr ?? bannerCtrl.imageUrl);
                                    } ,
                                    style: AppCss.nunitoblack14
                                        .textColor(appCtrl.appTheme.white)),
                                const VSpace(Sizes.s15)
                              ])),
                    ],),
                      Positioned(
                          right: 15.0,
                          top: 15.0,
                          child: InkResponse(
                              onTap: () => Navigator.of(context).pop(),
                              child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: appCtrl.appTheme.primary,
                                  child: Icon(Icons.close,
                                      size: 18,
                                      color: appCtrl.appTheme.white)))),
            CustomSnackBar(isAlert: bannerCtrl.isAlert),]),
            ),),);
          });
        });
  }
}
