import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:friendscircle/otpPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'color.dart' as color;
import 'package:http/http.dart' as http;
import 'global.dart' as global;
import 'package:flutter_html/style.dart' as style;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File _image;
  TextEditingController _controller1 = new TextEditingController();
  TextEditingController _controller2 = new TextEditingController();
  TextEditingController _controller3 = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  bool _passwordVisible = true;

  String htmlPrivacy = """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset='utf-8'>
      <meta name='viewport' content='width=device-width'>
      <title>Privacy Policy</title>
      <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
    </head>
    <body>
    <h2>Privacy Policy</h2>
<p>Your privacy is important to us. It is Find Friends' policy to respect your privacy regarding any information we may collect from you across our website, <a href="http://www.allotpark.buzz">http://www.allotpark.buzz</a>, and other sites we own and operate.</p>
<p>We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent. We also let you know why we’re collecting it and how it will be used.</p>
<p>We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we’ll protect within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use or modification.</p>
<p>We don’t share any personally identifying information publicly or with third-parties, except when required to by law.</p>
<p>Our website may link to external sites that are not operated by us. Please be aware that we have no control over the content and practices of these sites, and cannot accept responsibility or liability for their respective privacy policies.</p>
<p>You are free to refuse our request for your personal information, with the understanding that we may be unable to provide you with some of your desired services.</p>
<p>Your continued use of our website will be regarded as acceptance of our practices around privacy and personal information. If you have any questions about how we handle user data and personal information, feel free to contact us.</p>
<p>This policy is effective as of 1 July 2020.</p>
    </body>
    </html>
    """;
  String htmlTerms = """
  <!DOCTYPE html>
    <html>
    <head>
      <meta charset='utf-8'>
      <meta name='viewport' content='width=device-width'>
      <title>Terms &amp; Conditions</title>
      <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
    </head>
    <body>
    <h2>Find Friends Terms of Service</h2>
<h3>1. Terms</h3>
<p>By accessing the website at <a href="http://www.allotpark.buzz">http://www.allotpark.buzz</a>, you are agreeing to be bound by these terms of service, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws. If you do not agree with any of these terms, you are prohibited from using or accessing this site. The materials contained in this website are protected by applicable copyright and trademark law.</p>
<h3>2. Use License</h3>
<ol type="a">
   <li>Permission is granted to temporarily download one copy of the materials (information or software) on Find Friends' website for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:
   <ol type="i">
       <li>modify or copy the materials;</li>
       <li>use the materials for any commercial purpose, or for any public display (commercial or non-commercial);</li>
       <li>attempt to decompile or reverse engineer any software contained on Find Friends' website;</li>
       <li>remove any copyright or other proprietary notations from the materials; or</li>
       <li>transfer the materials to another person or "mirror" the materials on any other server.</li>
   </ol>
    </li>
   <li>This license shall automatically terminate if you violate any of these restrictions and may be terminated by Find Friends at any time. Upon terminating your viewing of these materials or upon the termination of this license, you must destroy any downloaded materials in your possession whether in electronic or printed format.</li>
</ol>
<h3>3. Disclaimer</h3>
<ol type="a">
   <li>The materials on Find Friends' website are provided on an 'as is' basis. Find Friends makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.</li>
   <li>Further, Find Friends does not warrant or make any representations concerning the accuracy, likely results, or reliability of the use of the materials on its website or otherwise relating to such materials or on any sites linked to this site.</li>
</ol>
<h3>4. Limitations</h3>
<p>In no event shall Find Friends or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Find Friends' website, even if Find Friends or a Find Friends authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you.</p>
<h3>5. Accuracy of materials</h3>
<p>The materials appearing on Find Friends' website could include technical, typographical, or photographic errors. Find Friends does not warrant that any of the materials on its website are accurate, complete or current. Find Friends may make changes to the materials contained on its website at any time without notice. However Find Friends does not make any commitment to update the materials.</p>
<h3>6. Links</h3>
<p>Find Friends has not reviewed all of the sites linked to its website and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by Find Friends of the site. Use of any such linked website is at the user's own risk.</p>
<h3>7. Modifications</h3>
<p>Find Friends may revise these terms of service for its website at any time without notice. By using this website you are agreeing to be bound by the then current version of these terms of service.</p>
<h3>8. Governing Law</h3>
<p>These terms and conditions are governed by and construed in accordance with the laws of Tamilnadu and you irrevocably submit to the exclusive jurisdiction of the courts in that State or location.</p>
    </body>
    </html>
  """;


  verifyMobile(mobile,context) async
  {
    Map jsonStr={"mobile":mobile};
    String jsonStrPost = jsonEncode(jsonStr);
    var response = await http.post(
        Uri.encodeFull(global.connection+"/login/alreadySignedUp"),
        headers: {"Content-Type" : "application/json"},body: jsonStrPost).then((value) => verifyMobileResponse(value,context));
  }
  verifyMobileResponse(res,context)
  {
      if(res.body == "FAILED")
        {
          Fluttertoast.showToast(
              msg: "User already exists",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: color.accentColor,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      else
        {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => OtpPage(mobile: _controller1.text , passWord: _controller2.text,image: _image,name:_controller3.text)
          ));
        }
  }




  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,width: 360 , height: 592,allowFontScaling: true);
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
        title: Text('Register'),
      ),
      body: Builder(
        builder: (context) =>  SingleChildScrollView(child: Container(
          height: ScreenUtil().setHeight(565) - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
          color: color.whiteColor,
          child: Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
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
                          child: (_image!=null)?Image.file(
                            _image,
                            fit: BoxFit.fill,
                          ):Image.network(
                            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setHeight(60)),
                    child: IconButton(
                      icon: Icon(
                        FontAwesomeIcons.camera,
                        size: ScreenUtil().setSp(20,allowFontScalingSelf: true),
                      ),
                      onPressed: () {
                        getImage();
                      },
                    ),
                  ),
                ],
              ),

              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                width: ScreenUtil().setWidth(300),
                child:TextFormField(
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color.mainColor)),labelText: "Name",filled: true,fillColor: color.whiteColor,border: OutlineInputBorder(),labelStyle: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil()
                      .setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.normal)),controller: _controller3,
                  validator: (value){
                    if(value.isEmpty){
                      return 'Enter Name';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                width: ScreenUtil().setWidth(300),
                child:TextFormField(
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color.mainColor)),labelText: "Mobile Number",filled: true,fillColor: color.whiteColor,border: OutlineInputBorder(),labelStyle: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil()
                      .setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.normal)),controller: _controller1,
                  validator: (value){
                    Pattern pattern = r'[0-9]{10}$';
                    RegExp regex = new RegExp(pattern);
                    if(value.isEmpty){
                      return 'Enter Mobile Number';
                    }
                    if (!regex.hasMatch(value))
                      return 'Enter Valid Phone Number';
                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                width: ScreenUtil().setWidth(300),
                child:TextFormField(
                   obscureText: _passwordVisible,
                  decoration: InputDecoration(
                      suffixIcon:
                      IconButton(
                        splashColor: Colors.transparent,
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: color.mainColor,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color.mainColor)),labelText: "Password",filled: true,fillColor: color.whiteColor,border: OutlineInputBorder(),labelStyle: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil()
                      .setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.normal)),controller: _controller2,
                  validator: (value){
                    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                    RegExp regExp = new RegExp(pattern);
                    if(value.isEmpty){
                      return 'Please Enter Password';
                    }
                    if(!regExp.hasMatch(value)){
                      return 'Minimum 1 Upper case\nMinimum 1 lowercase\nMinimum 1 Numeric Number\nMinimum 1 Special Character\nMinimum 8 Characters';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(30),
                    margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(190), ScreenUtil().setHeight(20), 0, 0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),),
                    child:FlatButton(
                    color: color.accentColor,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        print("Valid details");
                        verifyMobile(_controller2.text,context);

                      }
                      else{
                        setState(() => _autovalidate = true);

                      }

                    },
                    splashColor: Colors.blueGrey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                      Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                      Icon(Icons.arrow_forward,color: Colors.white,size: 20,)
                    ],)
                  ),),

                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0,ScreenUtil().setHeight(10),0,0),
                    height: ScreenUtil().setHeight(31),
                    width: ScreenUtil().setWidth(262),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        children: [
                          new TextSpan(
                            text: "By signing up you are agreeing to our ",
                            style: GoogleFonts.openSans(color: color.textColor,fontSize:ScreenUtil().setSp(10, allowFontScalingSelf: true), fontWeight: FontWeight.normal),
                          ),
                          new TextSpan(
                              text: "Terms Of Use ",
                              style: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(10, allowFontScalingSelf: true), fontWeight: FontWeight.normal,decoration: TextDecoration.underline),
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () {
                                  showDialog(context: context,child:
                                  Container(
                                    color: color.whiteColor,
                                    height: ScreenUtil().setHeight(500),
                                    width: ScreenUtil().setWidth(300),
                                    child:
                                    SingleChildScrollView(

                                        child: Html(
                                          data: htmlTerms,
                                          style: {"*" : style.Style(
                                              textDecoration: TextDecoration.none

                                          ),
                                          } ,

                                        )
                                    ),),);
                                }
                          ),
                          new TextSpan(
                            text: "and ",
                            style: GoogleFonts.openSans(color: color.textColor,fontSize:ScreenUtil().setSp(10, allowFontScalingSelf: true), fontWeight: FontWeight.normal),
                          ),
                          new TextSpan(
                              text: "Privacy Policy",
                              style: GoogleFonts.openSans(color: color.mainColor,fontSize:ScreenUtil().setSp(10, allowFontScalingSelf: true),textStyle: TextStyle(), fontWeight: FontWeight.normal,decoration: TextDecoration.underline),
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () {
                                  showDialog(context: context,child:
                                  Container(
                                    color: color.whiteColor,
                                    height: ScreenUtil().setHeight(500),
                                    width: ScreenUtil().setWidth(300),
                                    child:
                                    SingleChildScrollView(

                                        child: Html(
                                          data: htmlTerms,
                                          style: {"*" : style.Style(
                                              textDecoration: TextDecoration.none

                                          ),
                                          } ,

                                        )
                                    ),),);
                                }
                          ),
                        ],
                      ),
                    ),
//            Text("By signing up you are agreeing to our Terms Of Use and Privacy Policy",style: GoogleFonts.openSans(color: color.signInColor,fontSize:13.33, fontWeight: FontWeight.w200),textAlign: TextAlign.center,),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
        ),
      ),
    );
  }
}