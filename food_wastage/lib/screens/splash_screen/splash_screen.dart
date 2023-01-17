// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print
import 'package:flutter/material.dart';
import 'package:food_wastage/controllers/app_controller.dart';
import 'package:get/get.dart';
import '../../models/appuser.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../home_screen/home_screen.dart';
import '../location_permission_screen/location_permission_screen.dart';
import '../welcome_screen/welcome_screen.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      checkUserLoggedIn();
    });
  }


  Future<void> checkUserLoggedIn() async {
    Constants.appUser = await AppUser.getUserDetail();
    if(Constants.appUser.userEmail.isEmpty)
    {
      await AppController().signInGuest('guest@gmail.com', '12345678');
      Get.offAll(const LocationPermissonScreen());
      //Get.offAll(const WelcomeScreen());
    }
    else //if(Constants.appUser.latitude ==0 || Constants.appUser.longitude ==0)
      Get.offAll(const LocationPermissonScreen());
  }
  
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Constants.appThemeColor,
      body: Center(
        child: Text(
          'Waste Manager',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.fontSize * 7,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}