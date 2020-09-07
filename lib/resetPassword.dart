import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friendscircle/resetPasswordOtp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'global.dart' as global;
import 'color.dart' as color;

class ResetPassword extends StatefulWidget{
  @override
  _ResetPassword createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword>{
  TextEditingController _controller1 = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  verifyMobile(mobile) async{
    Map jsonStr={"mobile":mobile};
    String jsonStrPost = jsonEncode(jsonStr);
    var response = await http.post(
        Uri.encodeFull(global.connection+"/login/alreadySignedUp"),
        headers: {"Content-Type" : "application/json"},body: jsonStrPost).then((value) => verifiedRes(value));
  }
  verifiedRes(val)
  {
    print(val.body+" verify method");

    if(val.body.toString() == "SUCCESS") {
      Fluttertoast.showToast(
          msg: "Mobile number does not exist.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else{
      print("OTP PAGE CALL");
      Navigator.push(context, MaterialPageRoute(
        builder:(context) =>ResetPasswordOtp(mobile:_controller1.text),
      ));
    }
  }
  @override
  void dispose() {
    super.dispose();
    _controller1.dispose();
  }
  @override
  Widget build(BuildContext context){
    ScreenUtil.init(context, width: 360 , height: 592, allowFontScaling: true);
    return Scaffold(
        resizeToAvoidBottomPadding: true,

        body: SingleChildScrollView(child:Container(
        margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(40), ScreenUtil().setHeight(56),ScreenUtil().setWidth(40),0),
          child: Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                  child: SvgPicture.asset("assets/images/Logo_Blue.svg",width: ScreenUtil().setWidth(32),height: ScreenUtil().setWidth(32),)
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(38), 0, 0),
                    child: Text("Reset password", style: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(24 , allowFontScalingSelf: true), fontWeight: FontWeight.w600)),
                  ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(57), 0, 0),
                  height: ScreenUtil().setHeight(44),
                  width: ScreenUtil().setWidth(222),
                  child: Text("Please enter your registered mobile number", style: GoogleFonts.openSans(color: color.blackColor,fontSize:ScreenUtil().setSp(16, allowFontScalingSelf: true), fontWeight: FontWeight.w600)),
                ),
                Container(
                  height: ScreenUtil().setHeight(40),
                  width: ScreenUtil().setWidth(280),
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                  child: TextFormField(
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: color.whiteColor,
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: color.mainColor)),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: color.mainColor)),
                          labelText: "Mobile Number",
                          labelStyle: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.normal)
                    ),
                    controller: _controller1,
                    validator: (value){
                      Pattern pattern = r'[0-9]{10}$';
                      RegExp regex = new RegExp(pattern);
                      if(value.isEmpty){
                        return 'Enter Mobile Number';
                      }
                      if (!regex.hasMatch(value))
                        return 'Enter Valid Mobile Number';
                      return null;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: ScreenUtil().setHeight(40),
                      width: ScreenUtil().setWidth(146),
                      margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(88), 0, 0),
                      child: FlatButton(
                        color: color.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().setWidth(4))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(

                              child: Text("Send OTP",style:GoogleFonts.openSans(color: color.whiteColor, fontWeight: FontWeight.w600,fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true))),
                            ),
                            Container(
                                child : Icon(Icons.arrow_forward, color: color.whiteColor, size: ScreenUtil().setWidth(16),)
                            ),
                          ],
                        ),
                        onPressed: (){
                      if (_formKey.currentState.validate()){
                        verifyMobile(_controller1.text);
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
      ),),
    );
  }
}