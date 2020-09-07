import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Home.dart';
import 'global.dart' as global;
import 'navMenu.dart';
import 'color.dart' as color;
class CreateGroup extends StatefulWidget {
  double width,latitude,longitude;
  bool showSnack;
  String mobile,profile;
  CreateGroup({this.mobile,this.profile});
  @override
  _CreateGroup createState() => _CreateGroup(mobile: mobile,profile:profile);
}
class _CreateGroup extends State<CreateGroup> {
  TextEditingController _controller1 = new TextEditingController();
  TextEditingController _pinEditingController = new TextEditingController();
  String mobile,profile;
  _CreateGroup({this.mobile,this.profile});
  generatePassCode()
  {
    var rng = new Random();
    _pinEditingController.text = rng.nextInt(99999999).toString().padLeft(8,'0');
  }
  createGroupApi() async
  {
    if(_controller1.text == "")
      {
        Fluttertoast.showToast(
            msg: "Enter Group Name",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: color.accentColor,
            textColor: Colors.white,
            fontSize: 16.0
        );
        print("H");
      }
    else if(_pinEditingController.text.length < 8)
      {
        Fluttertoast.showToast(
            msg: "Enter passcode fully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: color.accentColor,
            textColor: Colors.white,
            fontSize: 16.0
        );
        print("I");
      }
    else
      {
        Map jsonStrPost = {"password" : _pinEditingController.text , "ownerMobile" : mobile, "groupName" : _controller1.text};
        var jsondata = jsonEncode(jsonStrPost);
        var jsonData = await http.post(
            Uri.encodeFull(global.connection+"/group/createGroup"),
            headers: {"Content-Type" : "application/json"},body: jsondata).then(createGroupApiResponse);
      }
  }
  createGroupApiResponse(res)
  {
      if(res.body == "ALREADY EXISTS")
        {
          Fluttertoast.showToast(
              msg: "Already active group exists",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: color.accentColor,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      else if(res.body == "SUCCESS")
        {
          Fluttertoast.showToast(
              msg: "Group created successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: color.accentColor,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => Home(mobile: mobile,profile:profile)
          ));
        }
  }




  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,width: 360 , height: 592,allowFontScaling: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.mainColor,
        title: Text('Create Group'),
      ),
      body:
      SingleChildScrollView(child: Container(
        color: color.whiteColor,
        margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
        child: Column(
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(300),
              child:TextFormField(
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: color.mainColor)),labelText: "Group Name",filled: true,fillColor: color.whiteColor,border: OutlineInputBorder(),labelStyle: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil()
                  .setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.normal)),controller: _controller1,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(30), 0, 0),
              width: ScreenUtil().setWidth(300),
              child: Text(
                "Passcode"
              )
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(10), 0, 0),
              width: ScreenUtil().setWidth(300),
              child: PinInputTextField(
                pinLength: 8,
                controller: _pinEditingController,
                decoration: BoxLooseDecoration(
                  gapSpace: ScreenUtil().setWidth(8),
                  strokeColor: color.mainColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: ()
              {
                generatePassCode();
              },
              child: Container(
                  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(160), ScreenUtil().setHeight(10), 0, 0),
                  child: Row(children: <Widget>[
                    Icon(Icons.refresh),
                    Text("Auto Generate Passcode",style: TextStyle(fontSize: ScreenUtil().setSp(12,allowFontScalingSelf: true)),),
                  ],)
              ),
            ),
            Container(
              color: color.accentColor,
              margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(50), 0, 0),
              width: ScreenUtil().setWidth(300),
              child:
              FlatButton(
                onPressed: ()
                {
                  createGroupApi();
                },
                child: Text("Create Group",style: TextStyle(color: color.whiteColor),),),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(10), 0, 0),
              height: ScreenUtil().setHeight(250),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/createGroup.jpg')
                )
              ),
            )

          ],
        ),
      )
      )
    );
  }

}