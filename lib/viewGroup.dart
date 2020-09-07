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
class ViewGroup extends StatefulWidget {

  String mobile,profile;
  ViewGroup({this.mobile,this.profile});
  @override
  _ViewGroup createState() => _ViewGroup(mobile: mobile,profile: profile);
}
class _ViewGroup extends State<ViewGroup> {

  String mobile,profile;

  _ViewGroup({this.mobile,this.profile});

  String groupName = "",
      groupId = "",
      groupPasscode = "";
  String ownerShipStatus = "";
  List<String> urls = [];
  bool apiCalled = true;
  void initState() {
    super.initState();
    getActiveGroupIdRecord();
  }

  getActiveGroupIdRecord() async
  {
    Map jsonStrPost = {"userMobile": mobile};
    var jsondata = jsonEncode(jsonStrPost);
    var jsonData = await http.post(
        Uri.encodeFull(global.connection + "/user/getGroup"),
        headers: {"Content-Type": "application/json"}, body: jsondata).then(
        getActiveGroupRecord);
  }

  getActiveGroupRecord(res) async
  {
    setState(() {
      apiCalled = false;
    });
    var result = jsonDecode(res.body);
    setState(() {
      apiCalled = true;
    });
    Map jsonStrPost = {"groupId": result['groupId']};
    var jsondata = jsonEncode(jsonStrPost);
    var jsonData = await http.post(
        Uri.encodeFull(global.connection + "/group/getActiveGroup"),
        headers: {"Content-Type": "application/json"}, body: jsondata).then(
        getActiveGroupRecordResponse);
  }

  getActiveGroupRecordResponse(res) {
    setState(() {
      apiCalled = false;
    });
    print(res.body);
    var result = jsonDecode(res.body);
    setState(() {
      apiCalled = false;
      ownerShipStatus =
      result['ownerMobile'].toString() == mobile ? "Admin" : "User";
      groupName = result['groupName'];
      groupId = result['groupId'].toString();
      groupPasscode = result['password'].toString();
    });
    getProfilesOfActiveUsers();
  }
  getProfilesOfActiveUsers() async
  {
    Map jsonStrPost = {"groupId": groupId};
    var jsondata = jsonEncode(jsonStrPost);
    var jsonData = await http.post(
        Uri.encodeFull(global.connection + "/user/getProfile"),
        headers: {"Content-Type": "application/json"}, body: jsondata).then(getProfilesOfActiveUsersResponse);
  }
  getProfilesOfActiveUsersResponse(res)
  {
    var result = jsonDecode(res.body);
    print(result['profile']);
    setState(() {
      result['profile'].forEach((element) {
        urls.add(element.toString());
      });
    });
  }

  leaveGroupApi() async
  {
    Map jsonStrPost = {"groupId": groupId, "userMobile": mobile};
    var jsondata = jsonEncode(jsonStrPost);
    var jsonData = await http.post(
        Uri.encodeFull(global.connection + "/user/leaveGroup"),
        headers: {"Content-Type": "application/json"}, body: jsondata).then(
        leaveGroupApiResponse);
  }

  leaveGroupApiResponse(res)
  {
    if(res.body == "SUCCESS")
      {
        Fluttertoast.showToast(
            msg: "Left from group",
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
  deleteGroupApi() async
  {
    Map jsonStrPost = {"groupId": groupId , "ownerMobile" : mobile};
    var jsondata = jsonEncode(jsonStrPost);
    var jsonData = await http.post(
        Uri.encodeFull(global.connection + "/group/deleteGroup"),
        headers: {"Content-Type": "application/json"}, body: jsondata).then(
        deleteGroupApiResponse);
  }

  deleteGroupApiResponse(res)
  {
    if(res.body == "SUCCESS")
    {
      Fluttertoast.showToast(
          msg: "Group deleted",
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
          title: Text('Active Group'),
        ),
        body:
        apiCalled ?
            Center(child: CircularProgressIndicator(

            ))
            :
        !(groupId== "" || groupId == null) ? SingleChildScrollView(child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                  child: Text("Member Status"),
                ),
                Container(
                  width: ScreenUtil().setWidth(220),
                  height: ScreenUtil().setHeight(30),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),border: Border.all(color: color.mainColor,width: 1.5)),
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                  child: Text(ownerShipStatus,style: TextStyle(fontWeight: FontWeight.w800,fontSize: ScreenUtil().setSp(18,allowFontScalingSelf: true)),),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                  child: Text("Group Credentials"),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, ScreenUtil().setHeight(20)),
                  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(20), ScreenUtil().setWidth(10), 0),
                  decoration: BoxDecoration(border: Border.all(width: 1)),
                  child: Column(children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: ScreenUtil().setWidth(80),
                        margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(20), ScreenUtil().setHeight(20), 0, 0),
                        child: Text("Group Name",style: TextStyle(color: color.mainColor,fontSize: ScreenUtil().setSp(14,allowFontScalingSelf: true)),),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(220),
                        height: ScreenUtil().setHeight(30),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),border: Border.all(color: color.mainColor,width: 1.5)),
                        margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(20), 0, 0),
                        child: Text(groupName,style: TextStyle(color: color.mainColor,fontSize: ScreenUtil().setSp(14,allowFontScalingSelf: true))),
                      ),

                    ],),
                  Row(
                    children: <Widget>[
                      Container(
                        width: ScreenUtil().setWidth(80),
                        margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(20), ScreenUtil().setHeight(20), 0, 0),
                        child: Text("Group ID",style: TextStyle(color: color.mainColor,fontSize: ScreenUtil().setSp(14,allowFontScalingSelf: true)),),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(220),
                        height: ScreenUtil().setHeight(30),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),border: Border.all(color: color.mainColor,width: 1.5)),
                        margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(20), 0, 0),
                        child: Text(groupId,style: TextStyle(color: color.mainColor,fontSize: ScreenUtil().setSp(14,allowFontScalingSelf: true))),
                      ),

                    ],),
                  Row(
                    children: <Widget>[
                      Container(
                        width: ScreenUtil().setWidth(80),
                        margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(20), ScreenUtil().setHeight(20), 0, 0),
                        child: Text("Passcode",style: TextStyle(color: color.mainColor,fontSize: ScreenUtil().setSp(14,allowFontScalingSelf: true)),),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(220),
                        height: ScreenUtil().setHeight(30),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),border: Border.all(color: color.mainColor,width: 1.5)),
                        margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(20), 0, 0),
                        child: Text(groupPasscode,style: TextStyle(color: color.mainColor,fontSize: ScreenUtil().setSp(14,allowFontScalingSelf: true))),
                      ),

                    ],),
                ],),),
                Container(
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                  child: Text("Active Members"),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 70,
                  child:ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                    for(var index = 0 ;index < urls.length ; index++)
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        width: 70,
                        decoration: BoxDecoration(
                            color: color.mainColor,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(urls[index]),
                            )
                        ),
                      ),

                    ],)
                  ,),
                ownerShipStatus == "Admin"
                ?

                Container(
                  color: color.accentColor,
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(40), 0, 0),
                  width: ScreenUtil().setWidth(320),
                  child:
                  FlatButton(
                    onPressed: ()
                    {
                      deleteGroupApi();
                    },
                    child: Text("Delete Group",style: TextStyle(color: color.whiteColor),),),
                )
                :
                Container(
                  color: color.accentColor,
                  margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(40), 0, 0),
                  width: ScreenUtil().setWidth(320),
                  child:
                  FlatButton(
                    onPressed: ()
                    {
                      leaveGroupApi();
                    },
                    child: Text("Leave Group",style: TextStyle(color: color.whiteColor),),),
                ),
            ],),
        )
        )
            :
            Container(alignment:Alignment.center,child: Text("No Active Group",style: TextStyle(fontSize: ScreenUtil().setSp(16,allowFontScalingSelf: true)),),)
    );
  }

}