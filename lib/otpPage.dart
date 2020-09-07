
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:http/http.dart' as http;
import 'global.dart' as global;
import 'home.dart';
import 'color.dart' as color;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:imgur/imgur.dart' as imgur;

import 'login.dart';



class OtpPage extends StatefulWidget{
  String  mobile, passWord ,name;
  File image;
  OtpPage({this.mobile, this.passWord , this.image , this.name});
  @override
  _OtpPage createState() => _OtpPage(mobile:mobile,passWord:passWord,image:image ,name  : name);


}


class _OtpPage extends State<OtpPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String mobile, passWord, name;
  String phno;
  String smsCode;
  String _verificationId;
  TextEditingController _pinEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  Timer _timer;
  int _start = 60;
  bool otpTimeout = false;
  bool otpExhausted = false;
  File image;
  BuildContext cont;
  bool pressed = false;
  _OtpPage({this.mobile, this.passWord,this.image , this.name});
  void initState()
  {
    super.initState();
    verifyOtp();
  }
  @override
  void dispose() {
    super.dispose();
    _pinEditingController.dispose();
  }
  void _onFormSubmitted(context) async {
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _pinEditingController.text);
    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult value) {
      String phone = value.user.phoneNumber;
      phone = phone.substring(3,phone.length);
      print(phone);
      signUp(phone,context);
    }).catchError((e) => failedOtpMessage(e));
  }
  failedOtpMessage(e){
    print(e);
    Fluttertoast.showToast(
        msg: "Invalid OTP",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  signUp(phone,context) async{
    if(pressed)
    {
      Fluttertoast.showToast(
          msg: "Processing please wait",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: color.accentColor,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else if(!pressed) {
      setState(() {
        pressed = true;
      });
      print("HELLO WORLD 0");
      if (image != null) {
        final client = imgur.Imgur(imgur.Authentication.fromToken(
            '4ec88d6b3a3bbf5cdab3abfdead56fb8ffd99762'));

        /// Upload an image from path
        await client.image
            .uploadImage(
            imagePath: image.path,
            title: 'A title',
            description: 'A description')
            .then((img) => signUpApi(img.link, context));

        print("HELLO WORLD 1");
      }
      else {
        signUpApi(
            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png",
            context);
      }
    }
  }
  signUpApi(res,context) async
  {
    print("HELLO WORLD 2");
    Map jsonStr={"mobile":mobile,"password":passWord,"profilePicture":res , "name" : name};
    String jsonStrPost = jsonEncode(jsonStr);
    var response = await http.post(
        Uri.encodeFull(global.connection+"/login/userSignUp"),
        headers: {"Content-Type" : "application/json"},body: jsonStrPost).then((value) => signUpRes(value,context));
  }
  signUpRes(val,context) {
    Fluttertoast.showToast(
        msg: "Registered successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: color.accentColor,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Navigator.push(context, MaterialPageRoute(
        builder:(context) =>Login()
    ));
    print(val.body);
  }
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            otpTimeout = true;
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  Future<void> verifyOtp() async{
    setState(() {
      otpTimeout = false;
      _start = 60;
    });
    startTimer();
    phno = "+91"+mobile;
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId)
    {
      this._verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId,[int forceCodeSent])
    {
      this._verificationId = verId;

      print("CODE SENT SUCCESSFULLY");
    };
    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser){
      print("verified");
    };
    final PhoneVerificationFailed failed = (AuthException exception)
    {
      setState(() {
        otpExhausted = true;
      });
      Fluttertoast.showToast(
          msg: "Please try again later",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print('${exception.message}');
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phno,
      timeout: const Duration(seconds:  60),
      verificationCompleted: verifiedSuccess,
      verificationFailed: failed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }
  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    return false; // return true if the route to be popped
  }
  @override
  Widget build(BuildContext context){
    ScreenUtil.init(context, width: 360 , height: 592, allowFontScaling: true);
    return
      WillPopScope(
        onWillPop: ()  =>  _willPopCallback(),
    child:Scaffold(
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
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(38), 0, 0),
                child: Text("Verify yourself", style: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(24 , allowFontScalingSelf: true), fontWeight: FontWeight.w600)),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(57), 0, 0),
                height: ScreenUtil().setHeight(44),
                width: ScreenUtil().setWidth(258),
                child: Text("Please enter the verification code we've just sent you.", style: GoogleFonts.openSans(color: color.blackColor,fontSize:ScreenUtil().setSp(16, allowFontScalingSelf: true), fontWeight: FontWeight.w600)),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                height: ScreenUtil().setHeight(40),
                width: ScreenUtil().setWidth(280),
                child : PinInputTextField(
                  pinLength: 6,
                  controller: _pinEditingController,
                  decoration: BoxLooseDecoration(
                    radius: Radius.circular(ScreenUtil().setWidth(3)),
                    strokeColor: color.mainColor,
                  ),
                ),
              ),
              otpExhausted ? Container()
                  :
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(24), 0, 0),
                child : RichText(
                  textAlign: TextAlign.center,
                  text: new TextSpan(
                    children: [
                      new TextSpan(
                        text: "If you didn't receive a code ",
                        style: GoogleFonts.openSans(color: color.blackColor,fontSize:ScreenUtil().setSp(12 , allowFontScalingSelf: true), fontWeight: FontWeight.normal),
                      ),
                      !otpTimeout ?
                      new TextSpan(
                        text: "resend in " + "$_start" + " seconds",
                        style: GoogleFonts.openSans(color: color.blackColor,fontSize:ScreenUtil().setSp(12 , allowFontScalingSelf: true), fontWeight: FontWeight.normal),
                      )
                          :
                      new TextSpan(
                          text: "click to resend",
                          style: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(12 , allowFontScalingSelf: true), fontWeight: FontWeight.normal,decoration: TextDecoration.underline),
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () {
                              verifyOtp();
                              setState(() {
                                cont = context;
                              });
                            }
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(39), 0, 0),
                    height: ScreenUtil().setHeight(40),
                    width: ScreenUtil().setWidth(120),
                    child: Material(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      color: color.accentColor,
                      child: InkWell(
                        splashColor: color.accentColor,
                        onTap: (){

                          if (_formKey.currentState.validate()){
                            _onFormSubmitted(context);
                          }
                          else{
                            setState(() => _autovalidate = true);
                          }
                        },
                        child: FlatButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                child: Text("Verify",style:GoogleFonts.openSans(color:color.whiteColor, fontWeight: FontWeight.w600,fontSize:ScreenUtil().setSp(14 , allowFontScalingSelf: true))),
                              ),
                              Container(
                                  child : Icon(Icons.arrow_forward, color: color.whiteColor, size: ScreenUtil().setWidth(16),)
                              ),
                            ],
                          ),

                        ),),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),),
    )
      );
  }

}
