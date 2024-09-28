
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mk_kabbani_admin/pages/categories/categories_screen.dart';
import 'package:mk_kabbani_admin/pages/current_version/current_version.dart';
import 'package:mk_kabbani_admin/pages/deals_of_the_day/deals_of_the_day.dart';
import 'package:mk_kabbani_admin/pages/homeSections/homeSections.dart';
import 'package:mk_kabbani_admin/pages/home_category_list/home_category_list_screen.dart';
import 'package:mk_kabbani_admin/pages/index/side_bar_menu_model.dart';
import 'package:mk_kabbani_admin/pages/timer_layout/timer_settings.dart';
import 'package:mk_kabbani_admin/pages/warranty_activation/warranty_activation_screen.dart';

import 'dart:html' as html;
import '../../config.dart';

class IndexLayoutController extends GetxController {
  ValueNotifier<bool> isOpen = ValueNotifier(true);
  GlobalKey<ScaffoldState>? scaffoldDrawerKey;
  GlobalKey<ScaffoldState>? scaffoldKey;
  int selectedIndex = 0;
  int? subSelectIndex;
  int staticPageIndex = 0;
  String pageName = "Home Banners".tr;
  bool isHover = false;
  bool isSubHover = false;
  int isSelectedHover = 1;
  int isSubSelectedHover = 1;

  final sidebarMenuConfigs = [
    SidebarMenuConfig(
      uri: routeName.banner,
      icon: svgAssets.banner,
      title: "Home Banners".tr,
    ),
    SidebarMenuConfig(
      uri: routeName.homeSections,
      icon: svgAssets.home,
      title: fonts.homeSections,
    ),

    SidebarMenuConfig(
      uri: routeName.categories,
      icon: svgAssets.category,
      title: "Categories".tr,
    ),

    SidebarMenuConfig(
      uri: routeName.homeCatList,
      icon: svgAssets.catSlider,
      title: "Home category slider".tr,
    ),

    SidebarMenuConfig(
      uri: routeName.dealsOfTheDay,
      icon: svgAssets.deals,
      title: "Special offers".tr,
    ),

    SidebarMenuConfig(
      uri: routeName.currentVersion,
      icon: svgAssets.version,
      title: "currentVersion".tr,
    ),

    SidebarMenuConfig(
      uri: routeName.timerSettings,
      icon: svgAssets.timer,
      title: fonts.timerSettings,
    ),

    SidebarMenuConfig(
      uri: routeName.notification,
      icon: svgAssets.bell,
      title: fonts.notification,
    ),
    SidebarMenuConfig(
      uri: routeName.warrantyActivation,
      icon: svgAssets.warranty,
      title: "Warranty Activation",
    ),
    SidebarMenuConfig(
      uri: '',
      icon: svgAssets.logout,
      title: fonts.logout,
    ),
  ];

  final ScrollController scrollController = ScrollController();

  //list of bottommost page
  List<Widget> widgetOptions = <Widget>[
    BannerPage(),
    HomeSectionsPage(),
    CategoriesScreen(),
    HomeCatListScreen(),
    DealsOfTheDayScreen(),
    CurrentVersionScreen(),
    TimerSettingsScreen(),
    NotificationPage(),
    WarrantyActivationScreen(),
    Container()
  ];



  @override
  void onReady() {
    // TODO: implement onReady
    appCtrl.getStorageData();
    super.onReady();
  }

  setKey(
      {GlobalKey<ScaffoldState>? scaffoldDrawerKey1,
      GlobalKey<ScaffoldState>? scaffoldKey1}) {
    scaffoldDrawerKey = scaffoldDrawerKey1;
    scaffoldKey = scaffoldKey1;
    update();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  drawerTap(index, context, {SidebarMenuConfig? value}) async {
    subSelectIndex = null;
    selectedIndex = index;
    pageName = value!.title.toString();
    if (!Responsive.isDesktop(context)) {
      Get.back();

    }
    // if (selectedIndex == 1) {
    //   final staticCtrl = Get.isRegistered<StaticController>()
    //       ? Get.find<StaticController>()
    //       : Get.put(StaticController());
    //   staticCtrl.getData();
    // }
    if (selectedIndex == 9) {
      FirebaseAuth.instance.signOut();
      selectedIndex == 0;
      html.window.localStorage[session.isLogin] = "false";
      appCtrl.storage.remove(session.isDarkMode);
      appCtrl.storage.remove(session.languageCode);
      Get.offAll(() => Login());
    }
    update();
  }
}
