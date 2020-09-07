import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:friendscircle/joinGroup.dart';
import 'package:friendscircle/profile.dart';
import 'package:friendscircle/viewGroup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'color.dart' as color;
import 'createGroup.dart';
import 'login.dart';
import 'global.dart' as global;
import 'package:http/http.dart' as http;
class NavDrawer extends StatelessWidget {
  String mobile,profile,name;
  NavDrawer({this.mobile,this.profile,this.name});
  void initState()
  {
    print(mobile);
  }

  logOut(context) async{
    Future<SharedPreferences> prefs =  SharedPreferences.getInstance();
    prefs.then((v) => clearUserKey(v,context));

  }
  clearUserKey(val,context)
  {
    val.clear();
    Navigator.push(context, MaterialPageRoute(
      builder:(context) =>Login(),
    ));

  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: color.mainColor
            ),
            child: Column(
              children: <Widget>[

                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: color.mainColor,
                      shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(profile),
                    )
                  ),
                ),
                Text(
                  mobile,
                  style: TextStyle(color: color.whiteColor, fontSize: 20),
                ),
          ],),

          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('View Group'),
            onTap: () => {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ViewGroup(mobile: mobile,profile:profile)
              ))
            },
          ),
          ListTile(
            leading: Icon(Icons.add_box),
            title: Text('Create Group'),
            onTap: () => {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => CreateGroup(mobile: mobile,profile:profile)
              ))
            },
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text('Join Group'),
            onTap: () => {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => JoinGroup(mobile: mobile,profile:profile)
              ))
            },
          ),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Profile'),
            onTap: () => {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Profile(mobile: mobile)
              ))
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {
              logOut(context)
             },
          ),
        ],
      ),
    );
  }
}