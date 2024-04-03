import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:mk_kabbani_admin/pages/index/index.dart';
import 'common/language/index.dart';
import 'common/theme/theme_service.dart';
import 'config.dart';

import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We're using the manual installation on non-web platforms since Google sign in plugin doesn't yet support Dart initialization.
  // See related issue: https://github.com/flutter/flutter/issues/96391
  GetStorage.init();
  Get.put(AppController());
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBcB_swDn8ob8QKBk2x-i9D9MDm6Zf4MMY",
        authDomain: "mk-kabbnai-uae.firebaseapp.com",
        projectId: "mk-kabbnai-uae",
        storageBucket: "mk-kabbnai-uae.appspot.com",
        messagingSenderId: "298947903325",
        appId: "1:298947903325:web:b1c8ac667b6b1e1d99f2b4",
        measurementId: "G-7SZZ312VWM"
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var scaffoldDrawerKey = GlobalKey<ScaffoldState>(debugLabel: "drawer");
  var scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "key2");


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    appCtrl.isLogin = html.window.localStorage[session.isLogin] ?? "false";
    SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
      label: fonts.appName.tr,
      primaryColor: Theme.of(context).primaryColor.value,
    ));
    return GetMaterialApp(
      builder: (context, widget) {
        return Title(
          title: fonts.appName.tr,
          color: appCtrl.appTheme.blackColor,
          child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                return !snapshot.hasData
                    ? MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaleFactor: 1.0),
                        child: widget!,
                      )
                    : Login();
              }),
        );
      },
      debugShowCheckedModeBanner: false,
      translations: Language(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      // tran
      title: fonts.appName.tr,
      home: appCtrl.isLogin == "true"
          ? Title(
              title: fonts.appName.tr,
              color: appCtrl.appTheme.blackColor,
              child:  IndexLayout(scaffoldDrawerKey: scaffoldDrawerKey,scaffoldKey: scaffoldKey,))
          : Login(),
      getPages: appRoute.getPages,
      theme: AppTheme.fromType(ThemeType.light).themeData,
      darkTheme: AppTheme.fromType(ThemeType.dark).themeData,
      themeMode: ThemeService().theme,
      scrollBehavior: MyCustomScrollBehavior(),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
