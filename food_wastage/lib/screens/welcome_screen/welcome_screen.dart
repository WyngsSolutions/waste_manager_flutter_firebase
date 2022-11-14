import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:food_wastage/screens/sign_in/sign_in.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../sign_up/sign_up.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({ Key? key }) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal *7,  SizeConfig.blockSizeVertical *10,  SizeConfig.blockSizeHorizontal *7, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(Icons.home, color: Constants.appThemeColor, size: SizeConfig.blockSizeVertical * 20,),
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
              child: Text(
                'Welcome to Waste Manager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: SizeConfig.fontSize * 2,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1, bottom: SizeConfig.blockSizeVertical * 4),
              child: Text(
                'A waste management marketplace for people to benefit from',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.4,
                  color: Colors.black,
                  fontSize: SizeConfig.fontSize * 1.8,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: (){
                Get.to(const SignUpScreen());
              },
              child: Container(
                height: SizeConfig.blockSizeVertical *6,
                decoration: BoxDecoration(
                  color: Constants.appThemeColor,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Center(
                  child: Text(
                    'Get Started',
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
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal *7,  SizeConfig.blockSizeVertical *2,  SizeConfig.blockSizeHorizontal *7, SizeConfig.blockSizeVertical *0),
        height: SizeConfig.blockSizeVertical * 7,
        child: Center(
          child: Align(
            alignment: Alignment.topCenter,
            child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Have an account? ',
              style: GoogleFonts.montserrat(color: Colors.grey, fontSize: SizeConfig.fontSize * 1.7),
              children: <TextSpan>[
                TextSpan(
                  text: 'Log in',
                  style: GoogleFonts.montserrat(color: Constants.appThemeColor, fontSize: SizeConfig.fontSize * 1.7, fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                  ..onTap = () {
                      Get.to(SignInScreen());
                    }
                  ),
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}