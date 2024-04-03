import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:mk_kabbani_admin/config.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/current_version_controller.dart';



class CurrentVersionScreen extends StatefulWidget {
  const CurrentVersionScreen({super.key});

  @override
  State<CurrentVersionScreen> createState() => _CurrentVersionScreenState();
}

class _CurrentVersionScreenState extends State<CurrentVersionScreen> {


  @override
  Widget build(BuildContext context) {
    CurrentVersionController currentVersionController = Get.put(CurrentVersionController());
    Size size = MediaQuery.of(context).size;
    return GetBuilder<CurrentVersionController>(
      builder: (_) => currentVersionController.currentVersionTxt.text.isNotEmpty ? Container(
        width: size.width,
        height: size.height * 0.45,
        child: Card(
            shadowColor: Colors.black26,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  CommonInputLayout(
                      controller: currentVersionController.currentVersionTxt,
                      title: fonts.currentVersion.tr,
                      hinText: fonts.currentVersion.tr),
                  Expanded(child: SizedBox()),
                  CommonButton(
                      onTap: (){
                        currentVersionController.updateFirestore(currentVersionController.currentVersionTxt.text,context);
                      },
                      title: fonts.submit.tr,
                      width: Sizes.s100,
                      style: AppCss.nunitoblack14
                          .textColor(appCtrl.appTheme.white))
                      .alignment(Alignment.bottomCenter),

                  SizedBox(height: 20,),

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
