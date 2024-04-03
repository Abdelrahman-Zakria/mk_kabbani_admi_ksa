import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/homeSectionsController.dart';

import '../../../config.dart';

class SectionImageLayoutChildren extends StatelessWidget {
  final StateSetter? setState;
  String? imageUrl;

  SectionImageLayoutChildren({Key? key, this.setState,this.imageUrl}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeSectionsController>(builder: (bannerCtrl) {

      bannerCtrl.imageUrlChild = this.imageUrl!;

      log("bannerCtrl.pickImage : ${bannerCtrl.imageUrlChild.isNotEmpty || bannerCtrl.pickImageChild != null  || bannerCtrl.webImageChild.isNotEmpty}");
      return Stack(alignment: Alignment.centerLeft, children: [
        DragDropLayout(
            onCreated: (ctrl) => bannerCtrl.controllerChild = ctrl,
            onDrop: (ev) async {
              log('Zone 1 drop: ${ev.name}');
              bannerCtrl.imageNameChild = ev.name;
              bannerCtrl.update();
              final bytes = await bannerCtrl.controllerChild!.getFileData(ev);
              bannerCtrl.getImageChild(dropImage: bytes);
            }),
        bannerCtrl.imageUrlChild.isNotEmpty && bannerCtrl.pickImageChild != null  && bannerCtrl.webImageChild.isNotEmpty
            ? CommonDottedBorder(
                    child: Image.memory(bannerCtrl.webImageChild, fit: BoxFit.fill))
                .inkWell(
                    onTap: () => bannerCtrl.getImageChild(
                        source: ImageSource.gallery, context: context))
            : bannerCtrl.imageUrlChild.isNotEmpty
                ? CommonDottedBorder(child: Image.network(bannerCtrl.imageUrlChild))
                    .inkWell(
                        onTap: () => bannerCtrl.getImageChild(
                            source: ImageSource.gallery, context: context))
                : bannerCtrl.pickImageChild == null
                    ? const ImagePickUp().inkWell(
                        onTap: () =>
                            bannerCtrl.onImagePickUpChild(setState, context))
                    : CommonDottedBorder(
                            child: Image.memory(bannerCtrl.webImageChild,
                                fit: BoxFit.fill))
                        .inkWell(
                            onTap: () => bannerCtrl.getImageChild(
                                source: ImageSource.gallery, context: context)),
      ])
          .height(bannerCtrl.isUploadSize ? Sizes.s40 : Sizes.s50)
          .paddingSymmetric(horizontal: Insets.i15);
    });
  }
}
