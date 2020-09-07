import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
class JoinGroup extends StatefulWidget {

  String mobile,profile;
  JoinGroup({this.mobile,this.profile});
  @override
  _JoinGroup createState() => _JoinGroup(mobile: mobile,profile:profile);
}
class _JoinGroup extends State<JoinGroup> {

  String mobile,profile;
  _JoinGroup({this.mobile,this.profile});
  TextEditingController _controller1 = new TextEditingController();
  TextEditingController _controller2 = new TextEditingController();

  void initState()
  {
    super.initState();
  }
  joinGroupApi() async
  {
    Map jsonStrPost = {"userMobile" : mobile, "groupId" : _controller1.text , "passcode" : _controller2.text};
    var jsondata = jsonEncode(jsonStrPost);
    var jsonData = await http.post(
        Uri.encodeFull(global.connection+"/user/joinGroup"),
        headers: {"Content-Type" : "application/json"},body: jsondata).then(joinGroupApiResponse);
  }

  joinGroupApiResponse(res)
  {
    if(res.body == "ALREADY IN GROUP")
      {
        Fluttertoast.showToast(
            msg: "Already active in a group",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: color.accentColor,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    else if(res.body == "INVALID")
      {
        Fluttertoast.showToast(
            msg: "Group ID or Passcode is incorrect",
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
          msg: "Joined in group",
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
    return
      Scaffold(
        appBar: AppBar(
          backgroundColor: color.mainColor,
          title: Text('Join Group'),
        ),
        body: SingleChildScrollView(child: Container(
          color:color.whiteColor,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
          child: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                  width: ScreenUtil().setWidth(300),
                  child: Text(
                      "Group ID"
                  )
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(10), 0, 0),
                width: ScreenUtil().setWidth(300),
                child: PinInputTextField(
                  pinLength: 8,
                  controller: _controller1,
                  decoration: BoxLooseDecoration(
                    gapSpace: ScreenUtil().setWidth(8),
                    strokeColor: color.mainColor,
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
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
                  controller: _controller2,
                  decoration: BoxLooseDecoration(
                    gapSpace: ScreenUtil().setWidth(8),
                    strokeColor: color.mainColor,
                  ),
                ),
              ),
              Container(
                color: color.accentColor,
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(40), 0, 0),
                width: ScreenUtil().setWidth(300),
                child:
                FlatButton(
                  onPressed: ()
                  {
                    joinGroupApi();
                  },
                  child: Text("Join Group",style: TextStyle(color: color.whiteColor),),),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(10), 0, 0),
                height: ScreenUtil().setHeight(250),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/joinGroup.jpg')
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