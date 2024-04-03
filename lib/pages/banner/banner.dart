import '../../config.dart';

class BannerPage extends StatelessWidget {
  final bannerCtrl = Get.put(BannerController());

  BannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (_) {
      return bannerCtrl.isLoading
          ? Center(
              child: CircularProgressIndicator(color: appCtrl.appTheme.primary))
          : bannerCtrl.banner.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Row(
                        children: [
                          TextButton.icon(
                              onPressed: () => bannerCtrl.addBannerDialog(),
                              icon: Icon(
                                Icons.add,
                                color: appCtrl.appTheme.primary,
                              ),
                              label: Text(
                                fonts.addBanner.tr,
                                style: AppCss.nunitoMedium14
                                    .textColor(appCtrl.appTheme.primary),
                              ),
                          ),
                          Expanded(child: SizedBox()),
                        ],
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
                                    Text("Image AR"),
                                    Text("Position"),
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
                            child: BannerList()),
                      ),
                    ]))
              : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        imageAssets.noData,
                        height: Sizes.s150,
                      ),
                      const VSpace(Sizes.s10),
                      Text(fonts.noBanner.tr),
                      const VSpace(Sizes.s10),
                      CommonButton(
                          title: fonts.addBanner.tr,
                          style: AppCss.nunitoMedium14
                              .textColor(appCtrl.appTheme.white),
                          width: Sizes.s150,
                          onTap: () => bannerCtrl.addBannerDialog()),
                    ],
                  ),
                );
    });
  }
}
