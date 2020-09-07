import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:friendscircle/preLoader.dart';
import 'package:friendscircle/profile.dart';
import 'package:friendscircle/resetPassword.dart';
import 'package:friendscircle/signUp.dart';
import 'Home.dart';
import 'color.dart' as color;
import 'login.dart';
import 'otpPage.dart';
void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(
      MaterialApp(
          title: 'Navigation Basics',
          home: MyApp(),theme: ThemeData(primaryColor: color.mainColor,accentColor: color.mainColor),
          debugShowCheckedModeBanner: false
      ));
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Preloader(title: "HELLO",);
//    return Login();
//   return Home(mobile: "9500164001");
  }

}
