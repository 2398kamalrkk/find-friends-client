import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'color.dart' as color;
import 'confirmResetPassword.dart';



class ResetPasswordOtp extends StatefulWidget{
  String mobile;
  ResetPasswordOtp({this.mobile});
  @override
  _ResetPasswordOtp createState() => _ResetPasswordOtp(mobile: mobile);
}

class _ResetPasswordOtp extends State<ResetPasswordOtp>{
  String mobile;
  String phno;
  String _verificationId;
  _ResetPasswordOtp({this.mobile});

  TextEditingController _pinEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Timer _timer;
  int _start = 60;
  bool otpTimeout = false;
  bool otpExhausted = false;
  void initState()
  {
    super.initState();
    print(mobile);
    verifyOtp();
  }
  @override
  void dispose() {
    super.dispose();
    _pinEditingController.dispose();
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
    };
    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser){
      _confirmResetPassword();
      print("verified");
    };
    final PhoneVerificationFailed failed = (AuthException exception)
    {
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

  void _onFormSubmitted() async {

    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _pinEditingController.text);
    _firebaseAuth.signInWithCredential(_authCredential)
        .then((AuthResult value) {

      _confirmResetPassword();
    });
  }

  _confirmResetPassword() async {
    Navigator.push(context, MaterialPageRoute(
        builder:(context) =>ConfirmResetPassword(mobile : mobile),
    ));
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
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(38), 0, 0),
                child: Text("Reset password", style: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(24 , allowFontScalingSelf: true), fontWeight: FontWeight.w600)),
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
                    child: FlatButton(
                      color: color.accentColor,
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
                      onPressed: (){
                        if (_formKey.currentState.validate()){
                          _onFormSubmitted();
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
        ),
    );
  }
}