import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'navMenu.dart';
import 'color.dart' as color;
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'global.dart' as global;
import 'package:websocket_manager/websocket_manager.dart';
import 'package:location/location.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class Home extends StatefulWidget {
  double width,latitude,longitude;
  bool showSnack;
  String mobile,profile;
  Home({this.mobile,this.profile});
  @override
  _Home createState() => _Home(mobile: mobile,profile:profile);
}
class _Home extends State<Home> {
  String mobile,profile;
  _Home({this.mobile,this.profile});
  Future<String> _initHome;
  GoogleMapController controller;
  String groupName = "",
      groupId = "",
      groupPasscode = "";
  String ownerShipStatus = "";
  List<String> urls = [];
  List<String> mobiles = [];
  List<String> status = [];
  bool apiCalled = true;
  WebsocketManager socket;
  Location location = new Location();
  bool opacity = false;
  LocationData _locationData;
  List<String> names = [];
  int currentProf = -1;
  void initState()
  {
  super.initState();
  getLocation();
  getActiveGroupIdRecord();
  socket = WebsocketManager(global.socket);
  if (socket != null) {
    socket.connect();
  }
  socket.onMessage((dynamic message) {
    print('New message: $message');
    if(message != "HELLO")
      {
        var res = jsonDecode(message);
        if(res['context'] == "REFRESH")
        {

          getActiveGroupIdRecord();
        }
        else if(res['context'] == "ONLINE")
        {
          setState(() {
            status[mobiles.indexOf(res['mobile'])] = "true";
            setMarkers(urls[mobiles.indexOf(res['mobile'])],res['mobile'],LatLng(0,0));
          });
        }
        else if(res['context'] == "OFFLINE")
        {
          status[mobiles.indexOf(res['mobile'])] = "false";
          setMarkers("https://i.ya-webdesign.com/images/blank-png-1.png",res['mobile'],LatLng(0,0));
        }
        else
        {
          print(mobiles);
          setMarkers(urls[mobiles.indexOf(res['mobile'])],res['mobile'],LatLng(double.parse(res['latitude']) , double.parse(res['longitude'])));
        }
      }
  });
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
  var name = "";
  getProfileResponse(val)
  {
    var res = jsonDecode(val.body);
    setState(() {
      profile = res['profilePicture'];
      name = res["name"];
    });
  }
  Set<Marker> allMarkers ={};



  getLocation() async
  {

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation().then((value) => moveCam(value));
  }

moveCam(location)
{
  _initHome=Future.value("position");
  controller.moveCamera(CameraUpdate.newLatLngZoom(LatLng(location.latitude,location.longitude),14));
  if(socket != null)
    {
      socket.send('{"context" : "SENDDATA" , "mobile" : "'+mobile+'" , "groupid" : "'+groupId+'" , "latitude" : "'+_locationData.latitude.toString()+'" , "longitude" : "'+_locationData.longitude.toString()+'"}');
    }
}











  getActiveGroupIdRecord() async
  {
    setState(() {
      apiCalled = true;
    });
    Map jsonStrPost = {"userMobile": mobile};
    var jsondata = jsonEncode(jsonStrPost);
    var jsonData = await http.post(
        Uri.encodeFull(global.connection + "/user/getGroup"),
        headers: {"Content-Type": "application/json"}, body: jsondata).then(
        getActiveGroupRecord);
  }

  getActiveGroupRecord(res) async
  {
    var result = jsonDecode(res.body);
    Map jsonStrPost = {"groupId": result['groupId']};
    var jsondata = jsonEncode(jsonStrPost);
    var jsonData = await http.post(
        Uri.encodeFull(global.connection + "/group/getActiveGroup"),
        headers: {"Content-Type": "application/json"}, body: jsondata).then(
        getActiveGroupRecordResponse);
  }

  getActiveGroupRecordResponse(res) {
    var result = jsonDecode(res.body);
    setState(() {
      ownerShipStatus =
      result['ownerMobile'].toString() == mobile ? "Admin" : "User";
      groupName = result['groupName'];
      groupId = result['groupId'].toString();
      groupPasscode = result['password'].toString();
    });
    if(groupId == "")
      {

      }
    else
      {
        socket.send('{"context" : "REGISTER" , "mobile" : "'+mobile+'" , "groupid" : "'+groupId+'"}');
        location.onLocationChanged.listen((LocationData currentLocation) {
          print(currentLocation);
          socket.send('{"context" : "SENDDATA" , "mobile" : "'+mobile+'" , "groupid" : "'+groupId+'" , "latitude" : "'+currentLocation.latitude.toString()+'" , "longitude" : "'+currentLocation.longitude.toString()+'"}');
        });
      }
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
    setState(() {
      urls.clear();
      mobiles.clear();
      status.clear();
      names.clear();
    });
    var result = jsonDecode(res.body);
    setState(() {
      result['profile'].forEach((element) {
        urls.add(element.toString());
      });
      result['status'].forEach((element) {
        status.add(element.toString());
      });
      var index = 0;
      result['allMobile'].forEach((element) {

            mobiles.add(element.toString());
            names.add(result['names'][index]);
            if(mobile == element.toString()) {
              setState(() {
                profile = urls[index];
              });
              setMarkers(
                  urls[index], element.toString(), LatLng(0,0));
            }
            index = index + 1;

      });
      status[mobiles.indexOf(mobile)] = "true";
      print("soinsdkjnfsknfsdkjnfskjnfksdjnfksdnfkjsdnfljsdf");
      print(result['status']);
      setState(() {
        apiCalled = false;
      });

    });

  }








  setMarkers(url,mob,latlng) async
  {
    await http.get(url).then((val) => setMarkersPins(val,mob,latlng));
  }
  Future<Uint8List> getBytesFromAsset(Uint8List data, int width) async {
    ui.Codec codec = await ui.instantiateImageCodec(data, targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }
  setMarkersPins(res,mob,latlng) async
  {
    final Uint8List markerIcon = await getBytesFromAsset(res.bodyBytes, 150).then((value) => set(value,mob,latlng));

  }
  set(res,mob,latlng)
  {
    setState(() {
      allMarkers.add(Marker(
          markerId: MarkerId(mob),
          position: latlng,
          icon: BitmapDescriptor.fromBytes(res)
        //icon: BitmapDescriptor.fromAsset('assets/images/Parking_Pin.png'),
      ));
    });
  }


  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    return false; // return true if the route to be popped
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,width: 360 , height: 592,allowFontScaling: true);
    return
      WillPopScope(
        onWillPop: ()  =>  _willPopCallback(),
    child:
    Scaffold(
      drawer: NavDrawer(mobile: mobile,profile:profile,name : name),
      appBar: AppBar(
        backgroundColor: color.mainColor,
        title: Text('Friends Circle'),
      ),
      body: Container(
        color: color.mainColor,
        child: Column(
          children: <Widget>[
            Container(
                height:ScreenUtil().setHeight(542) - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
                child: FutureBuilder<String>(
                    future: _initHome,
                    builder:(BuildContext context,AsyncSnapshot<String> snapshot) {
                      return GoogleMap(
                        markers: allMarkers,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,

                        onTap: (val){

                        },
                        onCameraIdle:(){

                        },
                        onCameraMove:(CameraPosition campos){

                        },

                        buildingsEnabled: false,
                        mapType: MapType.normal,
                        rotateGesturesEnabled: false,

                        onMapCreated: (GoogleMapController controller) {

                          setState(() {
                            this.controller = controller;
                          });
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(13,19),
                          zoom: 12.0,
                        ),
                      );
                    }
                )),
            Container(
              margin: EdgeInsets.fromLTRB(0,apiCalled ? ScreenUtil().setHeight(5) : 0,0,0),
              height: apiCalled ? ScreenUtil().setHeight(40) : ScreenUtil().setHeight(50),
              decoration: BoxDecoration(color: color.mainColor,border: Border.all(color: color.mainColor,width: ScreenUtil().setHeight(1))),
              child:
              groupId == "" && apiCalled
                  ?
              Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 1,
                  child :Text("No Active Group",style: TextStyle(color: color.whiteColor,fontSize: ScreenUtil().setSp(15,allowFontScalingSelf: true)),))
              :
              apiCalled ?
              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setWidth(16), 0, 0),
                width: ScreenUtil().setWidth(200),
                    child:
                    AnimatedOpacity(
                        onEnd: (){
                          setState(() {
                            if(opacity)
                              {
                                opacity = false;
                              }
                            else
                              {
                                opacity = true;
                              }
                          });
                        },
                        opacity: opacity ? 1 : 1,
                        duration: Duration(milliseconds: 600),
                        child:Text("Fetching location data from server",style: TextStyle(color: color.whiteColor,fontSize: ScreenUtil().setSp(13,allowFontScalingSelf: true)),))
                  )
              :
              ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(5), 0, ScreenUtil().setHeight(5)),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child:ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        for(var index = 0 ;index < urls.length ; index++)
                              Stack(children: <Widget>[


            SimpleTooltip(
            hideOnTooltipTap: true,
                animationDuration: Duration(milliseconds: 300),
                tooltipDirection: TooltipDirection.up,
                borderRadius: 0,
                borderWidth: 0,
                arrowTipDistance: 0,
                ballonPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),minimumOutSidePadding: 0,arrowBaseWidth: 10,arrowLength: 4,
                backgroundColor: color.accentColor,
                show:currentProf == index ? true : false,minHeight:ScreenUtil().setHeight(20),maxHeight:ScreenUtil().setHeight(40),minWidth: ScreenUtil().setWidth(100),maxWidth: ScreenUtil().setWidth(150),
                content:Center(child: Text(names[index],style: TextStyle(fontSize: ScreenUtil().setSp(12,allowFontScalingSelf: true),color: color.whiteColor,decoration: TextDecoration.none)),),
                child: GestureDetector(
                  onTap: ()
                    {
                      setState(() {
                        if(currentProf == index)
                          {
                            currentProf = -1;
                          }
                        else
                          {
                            currentProf = index;
                          }
                      });
                    },
                    child: Container(

                                  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(15), 0, 0, 0),
                                  width: ScreenUtil().setWidth(48),
                                  decoration: BoxDecoration(
                                      color: color.mainColor,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(urls[index]),
                                      )
                                  ),
                                )
                                )
                                )
                        ,
                                status[index] == "true"
                                ?
                                Container(
                                  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(42), ScreenUtil().setHeight(22), 0, 0),
                                  alignment: Alignment.bottomRight,
                                  decoration: BoxDecoration(color: Colors.lightGreenAccent,borderRadius: BorderRadius.all(Radius.circular(20))),
                                  width: ScreenUtil().setWidth(20),height: ScreenUtil().setHeight(20),)
                                    :
                                Container(
                                  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(42), ScreenUtil().setHeight(22), 0, 0),
                                  alignment: Alignment.bottomRight,
                                  decoration: BoxDecoration(color: Colors.redAccent,borderRadius: BorderRadius.all(Radius.circular(20))),
                                  width: ScreenUtil().setWidth(20),height: ScreenUtil().setHeight(20),)
                              ],)


                      ],)
                    ,),


                ],
              ),)
          ],
        ),
      )
    )
      );
  }

}