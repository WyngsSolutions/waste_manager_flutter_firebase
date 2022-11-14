// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors, deprecated_member_use, avoid_unnecessary_containers, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
//import '../../controllers/app_controller.dart';
import '../../controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../home_screen/home_screen.dart';
import '../location_permission_screen/location_permission_screen.dart';
//import '../home_screen/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isUser = true;

  @override
  void initState() {
    super.initState();
  }

  //LOGIN METHOD
  void signUpPressed() async {
    if (userName.text.isEmpty)
      Constants.showDialog("Please enter user name");
    else if (email.text.isEmpty)
      Constants.showDialog("Please enter email address");
    else if (!GetUtils.isEmail(email.text))
      Constants.showDialog( "Please enter valid email address");
    else if (password.text.isEmpty)
      Constants.showDialog( "Please enter password");
    else {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().signUpUser(userName.text, email.text, password.text);
      EasyLoading.dismiss();     
      if (result['Status'] == "Success")
      {
        Get.offAll(const LocationPermissonScreen());
      }
      else 
      {
        Constants.showDialog(result['ErrorMessage']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Constants.appThemeColor
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
          print('close');
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus)
            currentFocus.unfocus();
        },
        child: Container(
          margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1, left: SizeConfig.blockSizeHorizontal * 5, right: SizeConfig.blockSizeHorizontal * 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [    
              
              Container(
                child: Text(
                  'Create your account',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize :SizeConfig.fontSize * 2.5,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2.5),
                child: Text(
                  'Your email is not shown to others and is only used for verification',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize :SizeConfig.fontSize * 1.6,
                  ),
                ),
              ),
            
              Container(
                height: SizeConfig.blockSizeVertical *6,
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5
                  )
                ),
                child: Center(
                  child: TextField(
                    style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                    controller: userName,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter full name',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: SizeConfig.fontSize * 1.8),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20)
                    ),
                  ),
                ),
              ),

              Container(
                height: SizeConfig.blockSizeVertical *6,
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5
                  )
                ),
                child: Center(
                  child: TextField(
                    style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter email address',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: SizeConfig.fontSize * 1.8),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20)
                    ),
                  ),
                ),
              ),

              Container(
                height: SizeConfig.blockSizeVertical *6,
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5
                  )
                ),
                child: Center(
                  child: TextField(
                    style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter password',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: SizeConfig.fontSize * 1.8),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20)
                    ),
                  ),
                ),
              ),

              const Spacer(),
              GestureDetector(
                onTap: signUpPressed,
                child: Container(
                  height: SizeConfig.blockSizeVertical *6,
                  decoration: BoxDecoration(
                    color: Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(
                    child: Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.fontSize * 2.1,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal *7,  SizeConfig.blockSizeVertical *2,  SizeConfig.blockSizeHorizontal *7, SizeConfig.blockSizeVertical *0),
        height: SizeConfig.blockSizeVertical * 7,
      ),
    );
  }
}