import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:friendscircle/signUp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home.dart';
import 'color.dart' as color;
import 'login.dart';

const List<String> labels = [
  "Rotate",
  "Fade",
  "Typer",
  "Typewriter",
  "Scale",
  "Colorize",
  "TextLiquidFill"
];

class Preloader extends StatefulWidget {
  final String title;

  Preloader({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  _Preloader createState() => _Preloader();
}

class _Preloader extends State<Preloader> {


  void initState()
  {
    super.initState();
    _readUserDataLocal();
  }
  String mobile = "";
  _readUserDataLocal() async {
    Future<SharedPreferences> prefs =  SharedPreferences.getInstance();
    prefs.then(validateUser);
  }


  validateUser(val)
  {
    final key = 'mobile';
    final value = val.getString(key) ?? 0;
    if (value == 0) {
      var duration= Duration(milliseconds: 600);
      return Timer(duration,navLogin);
    }
    else {
      setState(() {
        mobile = value;
      });
      var duration= Duration(milliseconds: 600);
      return Timer(duration,navHome);
    }
  }
  navLogin()
  {
    Navigator.push(context, MaterialPageRoute(
        builder:(context) =>Login()
    ));
  }
  navHome()
  {
    Navigator.push(context, MaterialPageRoute(
        builder:(context) =>Home(mobile: mobile,profile: "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png",)
    ));
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,width: 360 , height: 592,allowFontScaling: true);
    return Scaffold(
      body: Column(
        children: <Widget>[

          Container(
            width:MediaQuery.of(context).size.width * 1,
            height:MediaQuery.of(context).size.height * 1,
            decoration: BoxDecoration(color: color.mainColor),
            child: Center(child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[

                    Center(child:
                    SizedBox(
                      width: ScreenUtil().setWidth(400),
                      child: TextLiquidFill(
                        loadDuration: Duration(milliseconds: 500),
                        waveDuration: Duration(milliseconds: 1000),
                        text: 'Friends Circle',
                        waveColor: color.accentColor,
                        boxBackgroundColor: color.mainColor,
                        textStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(45,allowFontScalingSelf: true),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    ),
                  ],
                ),
              ],
            ),),
          ),

        ],
      ),
    );
  }
}