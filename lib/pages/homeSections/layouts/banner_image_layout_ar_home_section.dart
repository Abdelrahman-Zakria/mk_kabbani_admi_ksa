import 'dart:developer';

import 'package:image_picker/image_picker.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/homeSectionsController.dart';

import '../../../config.dart';

class SectionImageLayoutAr extends StatelessWidget {
  final StateSetter? setState;

  const SectionImageLayoutAr({Key? key, this.setState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeSectionsController>(builder: (bannerCtrl) {
      log("bannerCtrl.pickImage : ${bannerCtrl.imageUrlAr.isNotEmpty || bannerCtrl.pickImageAr != null  || bannerCtrl.webImageAr.isNotEmpty}");
      return Stack(alignment: Alignment.centerLeft, children: [
        DragDropLayout(
            onCreated: (ctrl) => bannerCtrl.controller2 = ctrl,
            onDrop: (ev) async {
              log('Zone 1 drop: ${ev.name}');
              bannerCtrl.imageNameAr = ev.name;
              bannerCtrl.update();
              final bytes = await bannerCtrl.controller2!.getFileData(ev);
              bannerCtrl.getImageAr(dropImage: bytes);
            }),
        bannerCtrl.imageUrlAr.isNotEmpty && bannerCtrl.pickImageAr != null  && bannerCtrl.webImageAr.isNotEmpty
            ? CommonDottedBorder(
            child: Image.memory(bannerCtrl.webImageAr, fit: BoxFit.fill))
            .inkWell(
            onTap: () => bannerCtrl.getImageAr(
                source: ImageSource.gallery, context: context))
            : bannerCtrl.imageUrlAr.isNotEmpty
            ? CommonDottedBorder(child: Image.network(bannerCtrl.imageUrlAr))
            .inkWell(
            onTap: () => bannerCtrl.getImageAr(
                source: ImageSource.gallery, context: context))
            : bannerCtrl.pickImageAr == null
            ? const ImagePickUp().inkWell(
            onTap: () =>
                bannerCtrl.onImagePickUpAr(setState, context))
            : CommonDottedBorder(
            child: Image.memory(bannerCtrl.webImageAr,
                fit: BoxFit.fill))
            .inkWell(
            onTap: () => bannerCtrl.getImageAr(
                source: ImageSource.gallery, context: context)),
      ])
          .height(bannerCtrl.isUploadSize ? Sizes.s40 : Sizes.s50)
          .paddingSymmetric(horizontal: Insets.i15);
    });
  }
}
