// ignore_for_file: avoid_unnecessary_containers, curly_braces_in_flow_control_structures, library_private_types_in_public_api
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../set_location/set_location.dart';

class LocationPermissonScreen extends StatefulWidget {
  
  const LocationPermissonScreen({Key? key}) : super(key: key);

  @override
  _LocationPermissonScreenState createState() => _LocationPermissonScreenState();
}

class _LocationPermissonScreenState extends State<LocationPermissonScreen> {

  bool showLoading = true;
  //******* LOCATION *******\\
  Location location =  Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool isPermissionGiven = false;
  bool isGPSOpen = false;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    switchOnLocationPressed();
  }

  @override
  void dispose() {
    if(_timer != null)
      _timer!.cancel();
    super.dispose();
  }

  //****************************** LOCATION RELATED ********************************/
  void switchOnLocationPressed()async{
    //Permission Check
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) 
    {
      _permissionGranted = await location.requestPermission();
      
      if (_permissionGranted == PermissionStatus.deniedForever) {
        Constants.showTitleAndMessageDialog('Location Disabled', 'You have disabled location use for the app so please go to application settings and allow location use to continue');
        setState(() {
          showLoading = false;
        });
        return;
      }
      if (_permissionGranted == PermissionStatus.denied) {
        setState(() {
          showLoading = false;
        });
        return;
      }
      if (_permissionGranted != PermissionStatus.granted) {
         setState(() {
          showLoading = true;
        });
        return;
      }
    }

    if (_permissionGranted == PermissionStatus.granted)
      isPermissionGiven = true;
    

    //Service Check
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled)
    {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        startTimer();
        setState(() {
          showLoading = false;
        });
        return;
      }
      else
      {
        isGPSOpen = true;
        setState(() {
          showLoading = true;
        });
      }
    }
    else
    {
      isGPSOpen = true;
    }


    if(isGPSOpen && isPermissionGiven)
    {
      if(_timer != null)
        _timer!.cancel();
  
      _locationData = await location.getLocation();
      print(_locationData.latitude);
      print(_locationData.longitude);
      setUpUserLocation(_locationData.latitude!, _locationData.longitude!);
    }
    setState(() { });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          checkForGPS();
        },
      ),
    );  
  }

  void checkForGPS()async{
     _serviceEnabled = await location.serviceEnabled();
    if (_serviceEnabled)
    {
      isGPSOpen = true;
      switchOnLocationPressed();
    }
  }

  Future<void> notNowSelected() async {
    Constants.latitude = 14.0583;
    Constants.longitude = 108.2772;
    Get.to(const SetLocation());
  }

  Future<void> setUpUserLocation(double latitude , double longitude) async {
    Constants.latitude = latitude;
    Constants.longitude = longitude;
    Get.to(const SetLocation());
  }
  
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return  WillPopScope(
      onWillPop: () async {
        return false;
      },
      child : Scaffold(
        backgroundColor: Colors.white,
        body: (showLoading) ? Container(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Constants.appThemeColor),
            ),
          ),
        ) : Container(
          child: Column(
            children: [
              Container(
                height: SizeConfig.blockSizeVertical *80,
                width: SizeConfig.blockSizeHorizontal *100,
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Location Disabled", style: TextStyle(fontSize: 3 * SizeConfig.fontSize, color: Colors.black, fontWeight: FontWeight.bold),),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical *5,
                    ),
                    Text(
                      "Waste Manager works better when we\ncan detect your location", 
                      style: TextStyle(fontSize: 2 * SizeConfig.fontSize, color: Colors.black54, fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical *5,
                    ),
                    Icon(Icons.location_on, size: SizeConfig.blockSizeVertical *20, color: Constants.appThemeColor,)
                  ],
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical *20,
                width: SizeConfig.blockSizeHorizontal *100,
                margin: EdgeInsets.symmetric(horizontal: 20),
               // color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    GestureDetector(
                      onTap: switchOnLocationPressed,
                      child: Container(
                        height: SizeConfig.blockSizeVertical*7,
                        decoration: BoxDecoration(
                          color: Constants.appThemeColor,
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: Center(
                          child: Text(
                            "ENABLE",
                            style: TextStyle(fontSize: 1.8 * SizeConfig.fontSize, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: notNowSelected,
                      child: Container(
                        height: SizeConfig.blockSizeVertical*7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Constants.appThemeColor
                          )
                        ),
                        child: Center(
                          child: Text(
                            "NOT NOW",
                            style: TextStyle(
                              fontSize: 1.8 * SizeConfig.fontSize, color: Constants.appThemeColor
                            ),
                          ),
                        ),
                      ),
                    ),   

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
