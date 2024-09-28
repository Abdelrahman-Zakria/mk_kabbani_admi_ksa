import '../../../config.dart';

class DesktopNotificationLayout extends StatelessWidget {
  const DesktopNotificationLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (notificationCtrl) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CommonInputLayout(
                    controller: notificationCtrl.txtTitle,
                    title: fonts.title.tr,
                    hinText: fonts.enterNotificationTitle.tr,
                  ),
                ),
                const HSpace(Sizes.s15),
                Expanded(
                  child: CommonInputLayout(
                    controller: notificationCtrl.txtContent,
                    title: fonts.content.tr,
                    hinText: fonts.enterNotificationContent.tr,
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fonts.productCollectionId.tr,
                        style: AppCss.nunitoblack14,
                      ),
                      DropdownButton<String>(
                        value: notificationCtrl.selectedProductCollectionId,
                        hint: Text(fonts.productCollectionId.tr),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            enabled: false,
                            child: Text(
                              'Collections',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...notificationCtrl.homeCategoryList.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(category.name!),
                              ),
                            );
                          }).toList(),
                          DropdownMenuItem<String>(
                            value: null,
                            enabled: false,
                            child: Text(
                              'Products',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...notificationCtrl.productList.map((product) {
                            return DropdownMenuItem<String>(
                              value: product.id,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(product.name!),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (String? newValue) {
                          notificationCtrl.selectedProductCollectionId = newValue;
                          notificationCtrl.update();
                        },
                      ),
                    ],
                  ),
                ),
                const HSpace(Sizes.s10),
                const Expanded(
                  child: ProductCollectionRadio(),
                ),
              ],
            ).paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i20),
            CommonButton(
              onTap: () {
                var data = {
                  "title": notificationCtrl.txtTitle.text,
                  "content": notificationCtrl.txtContent.text,
                  "productCollectionId": notificationCtrl.selectedProductCollectionId,
                };
                notificationCtrl.sendPushNotification();
              },
              title: fonts.submit.tr,
              width: Sizes.s100,
              style: AppCss.nunitoblack14.textColor(appCtrl.appTheme.white),
            ).alignment(Alignment.bottomRight),
            const VSpace(Sizes.s20),
          ],
        );
      },
    );
  }
}
