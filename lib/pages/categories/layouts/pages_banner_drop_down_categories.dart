import 'package:mk_kabbani_admin/controllers/pages_controller/categories_controller.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/homeSectionsController.dart';

import '../../../config.dart';

class PageDropDownCategories extends StatelessWidget {
  const PageDropDownCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoriesController>(builder: (bannerCtrl) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: DropdownButton<int>(
          value: bannerCtrl.currentPerPage,
          items: bannerCtrl.perPages
              .map((e) => DropdownMenuItem<int>(
                  value: e,
                  child: Text("$e",
                      style: AppCss.nunitoMedium14
                          .textColor(appCtrl.appTheme.blackColor))))
              .toList(),
          onChanged: (dynamic value) {
            bannerCtrl.currentPerPage = value;
            bannerCtrl.currentPage = 1;
            bannerCtrl.resetData();
            bannerCtrl.update();
          },
          isExpanded: false,
        ),
      );
    });
  }
}
