// ignore_for_file: use_key_in_widget_constructors, curly_braces_in_flow_control_structures, prefer_const_constructors, avoid_unnecessary_containers, deprecated_member_use, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
//import '../../controllers/app_controller.dart';
import '../../controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
//import '../home_screen/home_screen.dart';
import '../home_screen/home_screen.dart';
import '../location_permission_screen/location_permission_screen.dart';

class SignInScreen extends StatefulWidget {
  
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {


  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  
  @override
  void initState() {
    super.initState();
  }

  //LOGIN METHOD
  void signInPressed() async {
    if (email.text.isEmpty)
      Constants.showDialog("Please enter email address");
    else if (!GetUtils.isEmail(email.text))
      Constants.showDialog( "Please enter valid email address");
    else if (password.text.isEmpty)
      Constants.showDialog( "Please enter password");
    else {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().signInUser(email.text, password.text);
      EasyLoading.dismiss();     
      if (result['Status'] == "Success") 
      {
        //if(Constants.appUser.latitude == 0 || Constants.appUser.longitude == 0)
          Get.offAll(const LocationPermissonScreen());
        //else
        //Get.offAll(HomeScreen(defaultPage: 0,));
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
      body:  GestureDetector(
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
                  'Enter your registered email\naddress',
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
                  'Please enter your account registration email to login and start using your account',
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
                    keyboardType: TextInputType.emailAddress,
                    controller: email,
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
                onTap: signInPressed,
                child: Container(
                  height: SizeConfig.blockSizeVertical *6,
                  decoration: BoxDecoration(
                    color: Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(
                    child: Text(
                      'Login',
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