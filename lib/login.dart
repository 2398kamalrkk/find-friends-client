import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:friendscircle/resetPassword.dart';
import 'package:friendscircle/signUp.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';
import 'global.dart' as global;
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'color.dart' as color;



class Login extends StatefulWidget{
  double latitude,longitude;
  @override
  _Login createState() => _Login();

}


class _Login extends State<Login>{
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  bool _passwordVisible = true;

  signIn() async
  {
    Map jsonStr={"mobile":_controller1.text,"password":_controller3.text};
    String jsonStrPost = jsonEncode(jsonStr);
    var response = await http.post(
        Uri.encodeFull(global.connection+"/login/login"),
        headers: {"Content-Type" : "application/json"},body: jsonStrPost).then((value) => signInThen(value));
  }
  signInThen(response) {
    var result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (result['status'] == "FAILED") {
        Fluttertoast.showToast(
            msg: "Check Mobile Number and Password.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.redAccent,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      else if (result['status'] == "NO USER") {
        Fluttertoast.showToast(
            msg: "No account. Please Register",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.orangeAccent,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      else if (result['status'] == "SUCCESS"){
        _saveUserDataLocal(_controller1.text);
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Home(mobile: _controller1.text,profile: result['profile'],)
        ));
      }
    }
  }
  _saveUserDataLocal(userId) async {
    Future<SharedPreferences> prefs =  SharedPreferences.getInstance();
    final key = 'mobile';
    final value = userId;
    prefs.then((pref){pref.setString(key, value);});
    print('saved $value');
  }

  @override
  void dispose() {
    super.dispose();
    _controller1.dispose();
    _controller3.dispose();
  }
  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    return false; // return true if the route to be popped
  }
  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    ScreenUtil.init(context,width: 360 , height: 592,allowFontScaling: true);

    return  WillPopScope(
        onWillPop: ()  =>  _willPopCallback(),
        child:Scaffold(
      resizeToAvoidBottomPadding: true,

      body: SingleChildScrollView(child:Container(
        height:MediaQuery.of(context).size.height * 1 ,

//        padding: EdgeInsets.fromLTRB(20, 80, 20, 0),
        padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(40), ScreenUtil().setHeight(51), ScreenUtil().setWidth(40), 0),

//        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*1),
        child :Form(
          child:Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Container(
                padding: EdgeInsets.fromLTRB(0,ScreenUtil().setHeight(40),ScreenUtil().setWidth(40),0),
              width: MediaQuery.of(context).size.width,
                child: Text("Great to have you back!",style: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil()
                    .setSp(24, allowFontScalingSelf: true), fontWeight: FontWeight.w600)),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(0,ScreenUtil().setHeight(40),0,0),
                child:Text("Sign In",style: GoogleFonts.openSans(color: color.accentColor,fontSize:ScreenUtil()
                    .setSp(16, allowFontScalingSelf: true), fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0,ScreenUtil().setHeight(18),0,0),
                child:
                TextFormField(keyboardType: TextInputType.number,decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: color.mainColor)),labelText: "Mobile Number",filled: true,fillColor: color.whiteColor,border: InputBorder.none,labelStyle: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil()
                    .setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.normal)),controller: _controller1,
                  ),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(0,ScreenUtil().setHeight(16),0,0),
                child:
                TextFormField(obscureText: _passwordVisible,decoration: InputDecoration(focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: color.mainColor)),labelText: "Password",filled: true,fillColor: color.whiteColor,border: InputBorder.none,labelStyle: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil()
                    .setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.normal),
                  suffixIcon:
                IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: color.mainColor,
                  ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),),controller: _controller3,
                  ),
              ),
              Container(
                alignment: Alignment.topRight,
                padding: EdgeInsets.fromLTRB(0,ScreenUtil().setHeight(23),0,0),

                child:
                    GestureDetector(
                      onTap: ()
                      {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ResetPassword()
                        ));
                      },
                      child:
                       Text(

                        "Forgot Password?",
                        style: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil()
                            .setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.w400,decoration: TextDecoration.underline),
//                      recognizer: new TapGestureRecognizer()
//                      ..onTap = () { launch('https://docs.flutter.io/flutter/services/UrlLauncher-class.html');
                      ),
                    ),

//            Text("By signing up you are agreeing to our Terms Of Use and Privacy Policy",style: GoogleFonts.openSans(color: color.signInColor,fontSize:13.33, fontWeight: FontWeight.w200),textAlign: TextAlign.center,),
              ),
              Container(

                margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(160),ScreenUtil().setHeight(25),0,0),
                width: ScreenUtil().setWidth(120),
                height: ScreenUtil().setHeight(40),
//        alignment: Alignment.topRight,
                
                child:Material(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  color: color.accentColor,

                  child:
                InkWell(
                  onTap:() {
                    signIn();

                  },


                  splashColor: color.mainColor,
                  child: FlatButton(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10),0,0,0),
                        child : Text("Sign In",style:TextStyle(color:color.whiteColor, fontWeight: FontWeight.w600,fontSize: ScreenUtil()
                            .setSp(14, allowFontScalingSelf: true))),
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(ScreenUtil().setHeight(10),0,0,0),
                          child : Icon(Icons.arrow_forward, color: color.whiteColor,size: ScreenUtil()
                              .setSp(14, allowFontScalingSelf: true),)
                      ),
                    ],
                  ),

                ),),),
              ),
//            Text("Existing User? Sign In"),
              Container(
                padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(87),ScreenUtil().setHeight(50),0,0),
                alignment: Alignment.center,
                child : Row(children:<Widget>[
                       Text(
                          "New User? ",
                          style:  GoogleFonts.openSans(color: color.accentColor,fontSize: ScreenUtil()
                              .setSp(12, allowFontScalingSelf: true))
                      ),
                GestureDetector(
                  child:
                      Text(
                        "Sign Up",
                        style:GoogleFonts.openSans(color: color.mainColor,decoration: TextDecoration.underline,fontSize: ScreenUtil()
                            .setSp(12, allowFontScalingSelf: true)),
//                      recognizer: new TapGestureRecognizer()
//                      ..onTap = () { launch('https://docs.flutter.io/flutter/services/UrlLauncher-class.html');
                      ),
                  onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                      builder:(context) =>ProfilePage()
                      ));
                  },
                )
                ])

              )
            ],
          ),
        ),
      ),

    )));
  }


}