import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:friendscircle/resetPasswordOtp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'color.dart' as color;
import 'package:http/http.dart' as http;
import 'global.dart' as global;
import 'login.dart';

class Profile extends StatefulWidget {
  String mobile;
  Profile({this.mobile});
  @override
  _Profile createState() => _Profile(mobile: mobile);
}

class _Profile extends State<Profile> {
  File _image;
  var mobile,profile, name = "";
  _Profile({this.mobile});
  initState()
  {
    super.initState();
    getProfile();
  }
  getProfile() async
  {
    Map jsonStr={"mobile":mobile};
    String jsonStrPost = jsonEncode(jsonStr);
    var response = await http.post(
        Uri.encodeFull(global.connection+"/login/getProfile"),
        headers: {"Content-Type" : "application/json"},body: jsonStrPost).then((value) => getProfileResponse(value));
  }
  getProfileResponse(val)
  {
    var res = jsonDecode(val.body);
    setState(() {
      profile = res['profilePicture'];
      name = res["name"];
    });
  }
  deleteAccount()
  {
    showDialog(
      context: context,

      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Delete Account",style: GoogleFonts.openSans(fontSize: ScreenUtil().setSp(16)),),
          content: new Text("Are you sure you want to delete your account ?",style: GoogleFonts.openSans(fontSize: ScreenUtil().setSp(14)),),
          actions: <Widget>[
            new FlatButton(
              child: new Text("No",style:GoogleFonts.openSans(color: color.mainColor,fontSize: ScreenUtil().setSp(14))),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes",style: GoogleFonts.openSans(color: color.mainColor,fontSize: ScreenUtil().setSp(14))),
              onPressed: () {
                Navigator.pop(context);
                deleteAccountApi();
                },
            ),
          ],
        );
      },
    );
  }
  deleteAccountApi() async
  {
    print("HELLO WORLD 2");
    Map jsonStr={"mobile":mobile};
    String jsonStrPost = jsonEncode(jsonStr);
    var response = await http.post(
        Uri.encodeFull(global.connection+"/login/delete"),
        headers: {"Content-Type" : "application/json"},body: jsonStrPost).then((value) => deleteAccountResponce(value));
  }
  deleteAccountResponce(res)
  {
    if(res.body == "SUCCESS")
      {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Login()
        ));
      }
  }
  resetPassword()
  {
    showDialog(
      context: context,

      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Reset Password",style: GoogleFonts.openSans(fontSize: ScreenUtil().setSp(16)),),
          content: new Text("Are you sure you want to reset password ?",style: GoogleFonts.openSans(fontSize: ScreenUtil().setSp(14)),),
          actions: <Widget>[
            new FlatButton(
              child: new Text("No",style:GoogleFonts.openSans(color: color.mainColor,fontSize: ScreenUtil().setSp(14))),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes",style: GoogleFonts.openSans(color: color.mainColor,fontSize: ScreenUtil().setSp(14))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ResetPasswordOtp(mobile: mobile,)
                ));
              },
            ),
          ],
        );
      },
    );
  }





  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 360, height: 592, allowFontScaling: true);
    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = image;
        print('Image Path $_image');
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text('Profile'),
      ),
      body: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   'Sign Up',
          //   style: TextStyle(color: color.accentColor, fontSize: 16.0),
          // ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: ScreenUtil().setWidth(50),
                  backgroundColor: Color(0xff476cfb),
                  child: ClipOval(
                    child: new SizedBox(
                      width: ScreenUtil().setWidth(180),
                      height: ScreenUtil().setHeight(180),
                      child: (profile != null)
                          ? Image.network(
                              profile,
                              fit: BoxFit.fill,
                            )
                          : Image.network(
                              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png",
                              fit: BoxFit.fill,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
              margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(80), ScreenUtil().setHeight(40), 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: ScreenUtil().setWidth(20),
                      child: Icon(
                        FontAwesomeIcons.userAlt,
                        color: color.accentColor,
                        size: ScreenUtil().setSp(18,allowFontScalingSelf: true),
                      )),
                  Container(
                    width: ScreenUtil().setWidth(200),
                    margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(20), 0, 0, 0),
                    child: Text(
                      name,
                      style: TextStyle(
                          color: color.mainColor,
                          fontSize: ScreenUtil().setSp(22,allowFontScalingSelf: true),
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              )),
          Container(
              margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(70), ScreenUtil().setHeight(20), 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: ScreenUtil().setWidth(20),
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Icon(
                        FontAwesomeIcons.phoneAlt,
                        color: color.accentColor,
                        size: ScreenUtil().setSp(18,allowFontScalingSelf: true),
                      )),
                  Container(
                    width: ScreenUtil().setWidth(200),
                    margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(20), 0, 0, 0),
                    child: Text(
                      '+91 ' + mobile,
                      style: TextStyle(
                          color: color.mainColor,
                          fontSize: ScreenUtil().setSp(22,allowFontScalingSelf: true),
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              )),
          Container(
            margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(120), 0, 0),
            width: ScreenUtil().setWidth(330),
            height: ScreenUtil().setHeight(50),
            decoration: BoxDecoration(border: Border.all(color: color.accentColor)),
            child: FlatButton(
                onPressed: () {
                  resetPassword();
                },
                splashColor: Colors.blueGrey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Reset Password',
                      style: TextStyle(color: color.accentColor, fontSize: 16.0),
                    ),
                    Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 20,
                    )
                  ],
                )),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(10), 0, 0),
            width: ScreenUtil().setWidth(330),
            height: ScreenUtil().setHeight(50),
            child: FlatButton(
                color: color.accentColor,
                onPressed: () {
                  deleteAccount();
                },
                splashColor: Colors.blueGrey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    )
                  ],
                )),
          ),
        ],
      )),
    );
  }
}
