import 'package:mk_kabbani_admin/controllers/pages_controller/homeSectionsController.dart';
import 'package:mk_kabbani_admin/pages/banner/layouts/banner_image_ar.dart';

import '../../../config.dart';
import 'package:mk_kabbani_admin/models/category_model.dart' as cat;


class AddBanner extends StatelessWidget {
  const AddBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeSectionsController _homeSecCtrl = Get.put(HomeSectionsController());
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return GetBuilder<HomeSectionsController>(
        builder: (secCtrl) {
          return GetBuilder<BannerController>(builder: (bannerCtrl) {
            return Stack(alignment: Alignment.topCenter, children: [
              AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: Container(
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
                          bannerCtrl.txtId.text != "" && bannerCtrl.txtTitle.text!= "" ?  BannerCommonClass().updateBannerTitle():BannerCommonClass().addBannerTitle(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 80),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width: 1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: DropdownButton(
                                    hint: Text("Choose collection"),
                                    underline: SizedBox.shrink(),
                                    items: secCtrl.homeCategoryList.map((cat.Category collection) {
                                      return DropdownMenuItem<String>(
                                        value: collection.id,

                                        child: Text(collection.name!),
                                      );
                                    }).toList(),
                                    onChanged: (val){
                                      // notificationCtrl.txtTitle.text = bannerCtrl.homeCategoryList.where((element) => element.id == val).first.name!;
                                      // notificationCtrl.update();
                                      bannerCtrl.txtTitle.text =  secCtrl.homeCategoryList.where((element) => element.id == val).first.name!;
                                      bannerCtrl.txtId.text =  secCtrl.homeCategoryList.where((element) => element.id == val).first.id!;
                                      bannerCtrl.update();
                                      // print("Val changed $val");
                                      // // bannerCtrl.changeNewSectionId(val);
                                      // setState((){
                                      //   bannerCtrl.txtTitle.text = bannerCtrl.homeCategoryList.where((element) => element.id == val).first.name!;
                                      //   bannerCtrl.txtTitleAr.text = bannerCtrl.homeCategoryList.where((element) => element.id == val).first.name!;
                                      //
                                      //   bannerCtrl.txtId.text = bannerCtrl.homeCategoryList.where((element) => element.id == val).first.id!;
                                      // });

                                    }),
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonTextBox(
                                        hinText: fonts.name.tr,
                                        controller: bannerCtrl.txtTitle),
                                    const VSpace(Sizes.s15),
                                    CommonTextBox(
                                        hinText: fonts.productCollectionId.tr,
                                        controller: bannerCtrl.txtId),
                                    const VSpace(Sizes.s15),
                                    const BannerProductCollection()
                                  ])),
                          const BannerImageLayout(),
                          const VSpace(Sizes.s10),
                          if (bannerCtrl.isUploadSize)
                            Column(children: [
                              const VSpace(Sizes.s5),
                              Text(fonts.imageError.tr,
                                  style: AppCss.nunitoMedium12
                                      .textColor(appCtrl.appTheme.redColor))
                            ]),
                          const VSpace(Sizes.s5),
                          Text("*English* Recommended size: 341 x 191"),
                          const VSpace(Sizes.s25),

                          const BannerImageArLayout(),
                          const VSpace(Sizes.s10),
                          if (bannerCtrl.isUploadSize)
                            Column(children: [
                              const VSpace(Sizes.s5),
                              Text(fonts.imageError.tr,
                                  style: AppCss.nunitoMedium12
                                      .textColor(appCtrl.appTheme.redColor))
                            ]),
                          const VSpace(Sizes.s5),
                          Text("*Arabic* Recommended size: 341 x 191"),
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
                                      : fonts.submit.tr,
                              onTap: () {
                                bannerCtrl.uploadFile();
                              } ,
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
                      ]))),
              CustomSnackBar(isAlert: bannerCtrl.isAlert),
            ]);
          });
        }
      );
    });
  }
}
