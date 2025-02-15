import 'package:briio_application/screens/auth/splash.dart';
import 'package:briio_application/screens/auth/welcome.dart';
import 'package:briio_application/utils/colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'controller/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BRIIO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: AppColors.mycolor,
          primaryColor: AppColors.logo2,
          inputDecorationTheme: const InputDecorationTheme(
            prefixIconColor: AppColors.logo2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.logo1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )),
      // home: Hom(),
      home: const Splash(),
    );
  }
}
//  disableCapture()async{
//   await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
// }