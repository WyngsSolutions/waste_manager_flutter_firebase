// ignore_for_file: prefer_const_constructors, deprecated_member_use, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../models/appuser.dart';

class Constants {
  static final Constants _singleton =  Constants._internal();
  static String appName = "Wastage Manager";
  static late AppUser appUser;
  static bool isUserOnline = false;
  static bool isFirstTimeAppLaunched = true;
  static late Function callBackFunction;
  static List categoryLists = [
    'Electronics & appliances',
    'Furniture',
    'Home & garden',
    'Baby & kids',
    'Women\'s fashion',
    'Mens\'s fashion',
    'Health & beauty',
    'Sports & leisure',
    'Games, hobbies & crafts',
    'Books & music',
  ];
  static double latitude = 31.44;
  static double longitude = 71.5433;
  //ONE SIGNAL
  static String oneSignalId = "5658963e-53a3-4a1e-a3cc-e8dc4a3fbde8";
  static String oneSignalRestKey = "ZjUxZGIyNjEtZWU1Ni00NTgzLTllNzctNjNjYTg5YzZhNzMy";
  //COLORS
  static Color appThemeColor = Colors.green;
  static Color secondaryColor = Color(0XFFdd8162);
  static Color tertiaryColor = Color(0xFF747474);
  //
  static String iosAppLink = "https://play.google.com/store/apps/details?id=com.kv.wyngs";
  static String androidAppLink = "https://play.google.com/store/apps/details?id=com.kv.wyngs";
  
  factory Constants() {
    return _singleton;
  }

  Constants._internal();

  static void showDialog(String message) {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(appName),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('OK')
          )
        ],
      )
    );
  }  

  static Future<File> resizePhotoIfBiggerThen1mb(File image) async{
    try{
      List<int> imageBytes = image.readAsBytesSync();
      double kbSize = imageBytes.length/1024;
      if(kbSize >300)
      {
        double quantity = (100 * 300000)/imageBytes.length;
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String savedPath = appDocDir.path + "/" + DateTime.now().microsecondsSinceEpoch.toString() + ".jpg";
        var result = await FlutterImageCompress.compressAndGetFile(
          image.absolute.path, savedPath,
          quality: quantity.toInt(),
        );
        return result!;
      }
      else
      {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String savedPath = appDocDir.path + "" + DateTime.now().microsecondsSinceEpoch.toString() + ".jpg";
        var result = await FlutterImageCompress.compressAndGetFile(
          image.absolute.path, savedPath,
          quality: 100,
        );
        return result!;
      }
    }
    catch(e){
      return File('');
    }
  }

  // static Future clearDocumentTempImages() async{
  //   try{
  //     Directory appDocDir = await getApplicationDocumentsDirectory();
  //     dynamic a = appDocDir.list();
  //     print(a);
  //     appDocDir.deleteSync(recursive: true);
  //     dynamic b = appDocDir.list();
  //     print(b);
  //   }
  //   catch(e){
  //     return;
  //   }
  // }

  static void showTitleAndMessageDialog(String title, String message) {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text('$title', style: TextStyle(fontWeight: FontWeight.w700),),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('OK')
          )
        ],
      )
    );
  }
}
