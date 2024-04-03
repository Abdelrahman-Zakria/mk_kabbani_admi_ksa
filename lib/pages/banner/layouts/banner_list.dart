import 'package:flutter/foundation.dart';

import 'package:responsive_table/responsive_table.dart';

import '../../../config.dart';

class BannerList extends StatelessWidget {

  BannerController bannerCt = Get.isRegistered<BannerController>() ? Get.find<BannerController>() : Get.put(BannerController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerCtrl) {
      return bannerCtrl.headers!.isNotEmpty
          ?
          ReorderableListView.builder(
            itemCount: bannerCtrl.source.length,
            itemBuilder: (context, index) => Card(
              key: ValueKey(bannerCtrl.source[index]['bannerId']),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      child: Text(
                        bannerCtrl.source[index]['name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Spacer(),
                    if (bannerCtrl.source[index]['image'] != null)
                      Image.network(
                        bannerCtrl.source[index]['image'],
                        width: Sizes.s200,
                        height: Sizes.s100,
                        fit: BoxFit.cover,
                      )
                    else
                      Image.network(
                        "https://trello-attachments.s3.amazonaws.com/5d64f19a7cd71013a9a418cf/640x480/1dfc14f78ab0dbb3de0e62ae7ebded0c/placeholder.jpg",
                        width: Sizes.s200,
                        height: Sizes.s100,
                        fit: BoxFit.cover,
                      ),
                    Spacer(),
                    Spacer(),
                    if (bannerCtrl.source[index]['imageAr'] != null)
                      Image.network(
                        bannerCtrl.source[index]['imageAr'],
                        width: Sizes.s200,
                        height: Sizes.s100,
                        fit: BoxFit.cover,
                      )
                    else
                      Image.network(
                        "https://trello-attachments.s3.amazonaws.com/5d64f19a7cd71013a9a418cf/640x480/1dfc14f78ab0dbb3de0e62ae7ebded0c/placeholder.jpg",
                        width: Sizes.s200,
                        height: Sizes.s100,
                        fit: BoxFit.cover,
                      ),
                    Spacer(),
                    Text(bannerCtrl.source[index]['priority'].toString()),
                    // Spacer(),
                    // CupertinoSwitch(
                    //   value: isSwitched,
                    //   onChanged: (val) async {
                    //     setState(() {
                    //       isSwitched = val;
                    //     });
                    //     categoryCtrl.updateIsShownValue(id: categoryCtrl.homeCategoryList[index].id, val: val);
                    //   },
                    // ),
                    Spacer(),

                    bannerCtrl.buildActions(bannerCtrl.source[index]),
                    Space(60, 0),
                  ],
                ),
              ),
            ),
            onReorder: (int oldIndex, int newIndex) {

                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                bannerCtrl.updatePrioritiesInFirestore(context, oldIndex, newIndex);
                bannerCtrl.update();
            },
          )
      // ResponsiveDatatable(
      //
      //         title: TextButton.icon(
      //             onPressed: () => bannerCtrl.addBannerDialog(),
      //             icon:  Icon(Icons.add,color: appCtrl.appTheme.primary,),
      //             label: Text(fonts.addBanner.tr,style: AppCss.nunitoMedium14.textColor(appCtrl.appTheme.primary),)),
      //         reponseScreenSizes: const [ScreenSize.xs],
      //         actions: const [BannerSearchAction()],
      //
      //         headers:
      //             bannerCtrl.headers!.isNotEmpty ? bannerCtrl.headers! : [],
      //         source: bannerCtrl.source,
      //         selecteds: bannerCtrl.selected,
      //         autoHeight: false,
      //         onChangedRow: (value, header) {
      //           /// print(value);
      //           /// print(header);
      //         },
      //         onSubmittedRow: (value, header) {
      //           /// print(value);
      //           /// print(header);
      //         },
      //         onTabRow: (data) {
      //           if (kDebugMode) {
      //             print(" dhfgdf : $data");
      //           }
      //         },
      //         onSort: (value)=> bannerCtrl.onSort(value),
      //         expanded: bannerCtrl.expanded,
      //         sortAscending: bannerCtrl.sortAscending,
      //         sortColumn: bannerCtrl.sortColumn,
      //         isLoading: bannerCtrl.isLoading,
      //         onSelect: (value, item) {
      //           if (kDebugMode) {
      //             print("$value  $item ");
      //           }
      //           if (value!) {
      //             bannerCtrl.selected.add(item);
      //             bannerCtrl.update();
      //           } else {
      //             bannerCtrl.selected
      //                 .removeAt(bannerCtrl.selected.indexOf(item));
      //             bannerCtrl.update();
      //           }
      //         },
      //         onSelectAll: (value) {
      //           if (value!) {
      //             bannerCtrl.selected =
      //                 bannerCtrl.source.map((entry) => entry).toList().cast();
      //             bannerCtrl.update();
      //           } else {
      //             bannerCtrl.selected.clear();
      //             bannerCtrl.update();
      //           }
      //         },
      //         footers: [
      //           Container(
      //               padding: const EdgeInsets.symmetric(horizontal: Insets.i15),
      //               child: Text(fonts.rowPerPage.tr,style: AppCss.nunitoMedium14.textColor(appCtrl.appTheme.primary),)),
      //           if (bannerCtrl.perPages.isNotEmpty) const PageDropDown(),
      //           Container(
      //               padding: const EdgeInsets.symmetric(horizontal: Insets.i15),
      //               child: Text(
      //                   "${bannerCtrl.currentPage} - ${bannerCtrl.currentPerPage} of ${bannerCtrl.total}",style: AppCss.nunitoMedium14.textColor(appCtrl.appTheme.blackColor),)),
      //           const ArrowBack(),
      //           const ArrowForward()
      //         ],
      //         headerDecoration: BannerCommonClass().headerDecoration(),
      //         selectedDecoration: BannerCommonClass().selectedDecoration(),
      //         headerTextStyle: TextStyle(color: appCtrl.appTheme.blackColor),
      //         rowTextStyle: TextStyle(color: appCtrl.appTheme.greenColor),
      //         selectedTextStyle: TextStyle(color: appCtrl.appTheme.blackColor),
      //       )



          : Container();
    });
  }
}
