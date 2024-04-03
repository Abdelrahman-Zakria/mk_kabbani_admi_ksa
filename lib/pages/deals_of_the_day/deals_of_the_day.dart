import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:mk_kabbani_admin/config.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/deals_of_the_day_controller.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/homeSectionsController.dart';
import 'package:mk_kabbani_admin/models/category_model.dart' as cat;


class DealsOfTheDayScreen extends StatefulWidget {
  const DealsOfTheDayScreen({super.key});

  @override
  State<DealsOfTheDayScreen> createState() => _DealsOfTheDayScreenState();
}

class _DealsOfTheDayScreenState extends State<DealsOfTheDayScreen> {


  @override
  Widget build(BuildContext context) {
    DealsOfTheDayController dealsOfTheDayCtrl = Get.put(DealsOfTheDayController());
    Size size = MediaQuery.of(context).size;
    return GetBuilder<DealsOfTheDayController>(
      builder: (_) => dealsOfTheDayCtrl.idController.text.isNotEmpty ? Container(
        width: size.width,
        height: size.height * 0.6,
        child: Card(
          shadowColor: Colors.black26,
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                GetBuilder<HomeSectionsController>(
                  builder: (bannerCtrl) {
                    return Container(
                      width: MediaQuery.of(context).size.width/5,
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
                                dealsOfTheDayCtrl.idController.text = bannerCtrl.homeCategoryList.where((element) => element.id == val).first.id!;
                                dealsOfTheDayCtrl.nameController.text = bannerCtrl.homeCategoryList.where((element) => element.id == val).first.name!;
                                dealsOfTheDayCtrl.update();
                              });

                            }),
                      ),
                    );
                  }
                ),
                CommonInputLayout(
                    controller: dealsOfTheDayCtrl.idController,
                    title: fonts.collectionId.tr,
                    hinText: fonts.collectionId.tr),
                Space(0, 10),
                CommonInputLayout(
                    controller: dealsOfTheDayCtrl.nameController,
                    title: fonts.name.tr,
                    hinText: fonts.name.tr),
                Space(0, size.height * 0.15),
                CommonButton(
                    onTap: (){
                      dealsOfTheDayCtrl.updateFirestore(dealsOfTheDayCtrl.idController.text,context);
                    },
                    title: fonts.submit.tr,
                    width: Sizes.s100,
                    style: AppCss.nunitoblack14
                        .textColor(appCtrl.appTheme.white))
                    .alignment(Alignment.bottomCenter),

              ],
            ),
          )
        ),
      ) : Container(child: Center(
    child: CircularProgressIndicator(color: appCtrl.appTheme.primary,),
    ),),

    ) ;
  }
}
