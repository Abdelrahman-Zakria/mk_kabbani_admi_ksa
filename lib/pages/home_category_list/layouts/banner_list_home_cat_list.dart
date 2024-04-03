import 'package:flutter/foundation.dart';
import 'package:mk_kabbani_admin/controllers/pages_controller/homeSectionsController.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/arrow_back_home_sections.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/arrow_forward_home_sections.dart';
import 'package:mk_kabbani_admin/pages/homeSections/layouts/pages_banner_drop_down_home_sections.dart';

import 'package:responsive_table/responsive_table.dart';

import '../../../config.dart';

class BannerListHomeSections extends StatelessWidget {
  const BannerListHomeSections({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeSectionsController>(builder: (bannerCtrl) {
      return bannerCtrl.homeSectionsHeaders!.isNotEmpty
          ? ResponsiveDatatable(
              title: TextButton.icon(
                  onPressed: () => bannerCtrl.addBannerDialog(),
                  icon:  Icon(Icons.add,color: appCtrl.appTheme.primary,),
                  label: Text(fonts.addSection.tr,style: AppCss.nunitoMedium14.textColor(appCtrl.appTheme.primary),)),
              reponseScreenSizes: const [ScreenSize.xs],
              actions: const [BannerSearchAction()],
              headers:
                  bannerCtrl.homeSectionsHeaders!.isNotEmpty ? bannerCtrl.homeSectionsHeaders! : [],
              source: bannerCtrl.source,
              selecteds: bannerCtrl.selected,
              autoHeight: false,
              onChangedRow: (value, header) {
                /// print(value);
                /// print(header);
              },
              onSubmittedRow: (value, header) {
                /// print(value);
                /// print(header);
              },
              onTabRow: (data) {
                if (kDebugMode) {
                  print(" dhfgdf : $data");
                }
              },
              onSort: (value)=> bannerCtrl.onSort(value),
              expanded: bannerCtrl.expanded,
              sortAscending: bannerCtrl.sortAscending,
              sortColumn: bannerCtrl.sortColumn,
              isLoading: bannerCtrl.isLoading,
              onSelect: (value, item) {
                if (kDebugMode) {
                  print("$value  $item ");
                }
                if (value!) {
                  bannerCtrl.selected.add(item);
                  bannerCtrl.update();
                } else {
                  bannerCtrl.selected
                      .removeAt(bannerCtrl.selected.indexOf(item));
                  bannerCtrl.update();
                }
              },
              onSelectAll: (value) {
                if (value!) {
                  bannerCtrl.selected =
                      bannerCtrl.source.map((entry) => entry).toList().cast();
                  bannerCtrl.update();
                } else {
                  bannerCtrl.selected.clear();
                  bannerCtrl.update();
                }
              },
              footers: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: Insets.i15),
                    child: Text(fonts.rowPerPage.tr,style: AppCss.nunitoMedium14.textColor(appCtrl.appTheme.primary),)),
                if (bannerCtrl.perPages.isNotEmpty) const PageDropDownHomeSections(),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: Insets.i15),
                    child: Text(
                        "${bannerCtrl.currentPage} - ${bannerCtrl.currentPerPage} of ${bannerCtrl.total}",style: AppCss.nunitoMedium14.textColor(appCtrl.appTheme.blackColor),)),
                const ArrowBackHomeSections(),
                const ArrowForwardHomeSections()
              ],
              headerDecoration: BannerCommonClass().headerDecoration(),
              selectedDecoration: BannerCommonClass().selectedDecoration(),
              headerTextStyle: TextStyle(color: appCtrl.appTheme.blackColor),
              rowTextStyle: TextStyle(color: appCtrl.appTheme.greenColor),
              selectedTextStyle: TextStyle(color: appCtrl.appTheme.blackColor),
            )
          : Container();
    });
  }
}
