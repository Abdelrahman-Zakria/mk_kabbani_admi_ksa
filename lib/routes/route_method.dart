//app file

import 'package:mk_kabbani_admin/pages/categories/categories_screen.dart';
import 'package:mk_kabbani_admin/pages/contact_us/contact_us.dart';
import 'package:mk_kabbani_admin/pages/current_version/current_version.dart';
import 'package:mk_kabbani_admin/pages/deals_of_the_day/deals_of_the_day.dart';
import 'package:mk_kabbani_admin/pages/homeSections/homeSections.dart';
import 'package:mk_kabbani_admin/pages/home_category_list/home_category_list_screen.dart';
import 'package:mk_kabbani_admin/pages/privacy_policy/privacy_policy.dart';
import 'package:mk_kabbani_admin/pages/terms_condition/terms_condition.dart';
import 'package:mk_kabbani_admin/pages/timer_layout/timer_settings.dart';
import 'package:mk_kabbani_admin/pages/warranty_activation/warranty_activation_screen.dart';
import 'package:mk_kabbani_admin/routes/screen_list.dart';

import '../config.dart';
import 'route_name.dart';

RouteName _routeName = RouteName();

class AppRoute {
  final List<GetPage> getPages = [
    GetPage(name: _routeName.login, page: () =>  Login()),
    GetPage(name: _routeName.index, page: () =>  const IndexLayout()),
    GetPage(name: _routeName.banner, page: () =>  BannerPage()),
    GetPage(name: _routeName.homeSections, page: () =>  HomeSectionsPage()),
    GetPage(name: _routeName.categories, page: ()=> CategoriesScreen()),
    GetPage(name: _routeName.homeCatList, page: ()=> HomeCatListScreen()),

    GetPage(name: _routeName.dealsOfTheDay, page: ()=> DealsOfTheDayScreen()),

    GetPage(name: _routeName.currentVersion, page: ()=> CurrentVersionScreen()),
    GetPage(name: _routeName.warrantyActivation, page: () =>  WarrantyActivationScreen()),

    GetPage(name: _routeName.timerSettings, page: () =>  TimerSettingsScreen()),
    GetPage(name: _routeName.aboutsUs, page: () =>  AboutUsPage()),
    GetPage(name: _routeName.contactUs, page: () =>  ContactUs()),
    GetPage(name: _routeName.termsCondition, page: () =>  TermsCondition()),
    GetPage(name: _routeName.privacyPolicy, page: () =>  PrivacyPolicy()),
    GetPage(name: _routeName.notification, page: () =>  NotificationPage()),
  ];
}
