import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart' as global;
import 'login.dart';
import 'color.dart' as color;

class ConfirmResetPassword extends StatefulWidget{
  String mobile;
  ConfirmResetPassword({this.mobile});
  @override
  _ConfirmResetPassword createState() => _ConfirmResetPassword(mobile: mobile);
}

class _ConfirmResetPassword extends State<ConfirmResetPassword> {
  String mobile;
  _ConfirmResetPassword({this.mobile});
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  final globalKey = GlobalKey<ScaffoldState>();

  resetPassword(phone, password) async{
    print(phone);
    Map jsonStr={"mobile":phone,"password":password};
    String jsonStrPost = jsonEncode(jsonStr);
    var response = await http.post(
        Uri.encodeFull(global.connection+"/login/reset"),
        headers: {"Content-Type" : "application/json"},body: jsonStrPost).then((value) => resetPasswordRes(value));
  }
  resetPasswordRes(val){
    logOut();
    print(val.statusCode);
    Navigator.push(context, MaterialPageRoute(
      builder:(context) => Login(),
    ));
  }
  logOut() async{
    Future<SharedPreferences> prefs =  SharedPreferences.getInstance();
    prefs.then(clearUserKey);

  }
  clearUserKey(val) {
    val.clear();
  }
  @override
  void dispose() {
    super.dispose();
    _controller1.dispose();
    _controller1.dispose();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 360 , height: 592, allowFontScaling: true);
    return Scaffold(
      key: globalKey,
      resizeToAvoidBottomPadding: false,
      body: Container(
        margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(40), ScreenUtil().setHeight(56),ScreenUtil().setWidth(40),0),
        child: Form(
          key: _formKey,
          autovalidate: _autovalidate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
              ),
              Container(
                    margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(38), 0, 0),
                    child: Text("Reset password", style: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(24, allowFontScalingSelf: true), fontWeight: FontWeight.w600)),
                  ),
              Container(
//                width: ScreenUtil().setWidth(159),
                height: ScreenUtil().setHeight(22),
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(62), 0, 0),
                child: Text("Enter a new password", style: GoogleFonts.openSans(color: color.blackColor,fontSize:ScreenUtil().setSp(16, allowFontScalingSelf: true), fontWeight: FontWeight.w600)),
              ),
              Container(
                width: ScreenUtil().setWidth(280),
                height: ScreenUtil().setHeight(40),
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(18), 0, 0),
                child: TextFormField(
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: color.whiteColor,
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: color.mainColor)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: color.mainColor)),
                        labelText: "New Password",
                        labelStyle: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.normal)
                    ),
                  controller: _controller1,
                    validator: (value){
//                      String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
//                      RegExp regExp = new RegExp(pattern);
                      if(value.isEmpty){
                        return 'Please Enter Password';
                      }
//                      if(!regExp.hasMatch(value)){
//                        return 'Minimum 1 Upper case\nMinimum 1 lowercase\nMinimum 1 Numeric Number\nMinimum 1 Special Character';
//                      }
                      return null;
                    },
                  obscureText: true,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(16), 0, 0),
                child: TextFormField(
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: color.whiteColor,
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: color.mainColor)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: color.mainColor)),
                        labelText: "Confirm Password",
                        labelStyle: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.normal)
                    ),
                  controller: _controller2,
                  validator: (value){
                      String confirmPassword = _controller1.text;
                      if(value.isEmpty){
                        return 'Please Enter Confirm Password';
                      }
                      if(value != confirmPassword){
                        return 'Password does not match';
                      }
                      return null;
                  },
                  obscureText: true,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(35), 0, 0),
                    width: ScreenUtil().setWidth(120),
                    height: ScreenUtil().setHeight(40),
                    child: FlatButton(
                      color: color.accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.00)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            child: Text("Update",style:GoogleFonts.openSans(color: color.whiteColor, fontWeight: FontWeight.w600,fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true))),
                          ),
                          Container(
                              child : Icon(Icons.arrow_forward, color: color.whiteColor,size: ScreenUtil().setWidth(16),)
                          ),
                        ],
                      ),
                      onPressed: (){
                        if (_formKey.currentState.validate()) {
                          print("Valid details");
                          resetPassword(mobile, _controller1.text);
                        }
                        else{
                          setState(() => _autovalidate = true);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}