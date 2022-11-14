// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class AppUser {
  String userId = "";
  String userName = "";
  String userEmail = "";
  String userPhoneNumber = "";
  String userPicture = "";
  String oneSignalUserID = "";
  List myFavorites = [];
  String addedDate = "";
  double latitude = 0;
  double longitude = 0;
  int searchRadius = 20;
  int totalReviewsCount = 0;
  double totalRating = 0;

  AppUser({this.userId = '', this.userName ='', this.userEmail = '', this.userPhoneNumber = "", this.longitude= 0, this.latitude = 0, this.userPicture = '', this.oneSignalUserID = "", this.addedDate = "", this.searchRadius = 20, this.totalReviewsCount =0, this.totalRating = 0});
  
  factory AppUser.fromJson(dynamic json) {
    AppUser user =  AppUser(
      userId: json['userId'],
      userName: json['userName'],
      userEmail : json['userEmail'],
      userPhoneNumber: json['userPhoneNumber'],
      userPicture: json["userPicture"],
      latitude: json["latitude"],
      longitude: json['longitude'],
      searchRadius : json['searchRadius'],
      oneSignalUserID: json['oneSignalUserId'],
      addedDate : json['addedTime'].toDate().toString(),
      totalReviewsCount: json['totalReviewsCount'],
      totalRating: json['totalRating'].toDouble()
    );  
    return user;
  }

  Future saveUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userId", userId);
    prefs.setString("userName", userName);
    prefs.setString("userEmail", userEmail);
    prefs.setString("userPhoneNumber", userPhoneNumber);
    prefs.setString("userPicture", userPicture);
    prefs.setInt('searchRadius', searchRadius);
    prefs.setDouble("latitude", latitude);
    prefs.setDouble("longitude", longitude);
    prefs.setString("oneSignalUserId", oneSignalUserID);
    prefs.setString("addedDate", addedDate);    
  }

  static Future<AppUser> getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppUser user = AppUser();
    user.userId = prefs.getString("userId") ?? "";
    user.userName = prefs.getString("userName") ?? "";
    user.userEmail = prefs.getString("userEmail") ?? "";
    user.userPhoneNumber = prefs.getString("userPhoneNumber") ?? "";
    user.userPicture = prefs.getString("userPicture") ?? "";
    user.latitude = prefs.getDouble("latitude") ?? 0;
    user.longitude = prefs.getDouble("longitude") ?? 0;
    user.searchRadius = prefs.getInt('searchRadius') ?? 0;
    user.oneSignalUserID = prefs.getString('oneSignalUserId') ?? "";
    user.addedDate = prefs.getString('addedDate') ?? "";
    return user;
  }

  static Future saveOneSignalUserId(String oneSignalUserToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("oneSignalUserId", oneSignalUserToken);
  }

  static Future getOneSignalUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("oneSignalUserId") ?? "";
  }

  static Future saveIsSubscribed(bool isSubscribed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("IsSubscribed", isSubscribed);
  }

  static Future deleteUserAndOtherPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

///FIRESTORE METHODS
  Future<dynamic> signUpUser(AppUser user) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(user.userId).set({
      'userId': user.userId,
      'userName': user.userName,
      'userEmail': user.userEmail,
      'userPhoneNumber': user.userPhoneNumber,
      'userPicture': user.userPicture,
      'latitude': user.latitude,
      'longitude' : user.longitude,
      'searchRadius' : user.searchRadius,
      'myFavorites' : user.myFavorites,
      'oneSignalUserId' : user.oneSignalUserID,
      'addedTime' : FieldValue.serverTimestamp(),
      'totalRating' : 0.0,
      'totalReviewsCount' : 0
    }).then((_) async {
      print("success!");
      return user;
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }

  static Future<dynamic> getLoggedInUserDetail(AppUser user) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .doc(user.userId)
    .get()
    .then((value) async {
      if(value.exists)
      {
        AppUser userTemp = AppUser.fromJson(value.data()!);
        userTemp.userId = user.userId;
        return userTemp;
      }
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }

  static Future<dynamic> getUserDetailByUserId(String userId) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .where('userId', isEqualTo: userId)
    .get()
    .then((value) async {
      AppUser userTemp = AppUser.fromJson(value.docs[0].data());
      userTemp.userId = userId;
      return userTemp;
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }

  //UPDATE PUSH TOKEN
  Future<dynamic> updateUserLocation(double latitude, double longitude, String userDistrict) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(Constants.appUser.userId)
    .update({
      'latitude': latitude,
      'longitude' : longitude,
      'userDistrict' : userDistrict
     }).then((_) async {
      print("success!");
      Constants.appUser.latitude = latitude;
      Constants.appUser.longitude = longitude;
      await Constants.appUser.saveUserDetails();
      return true;
    }).catchError((error) {
      print("Failed to update: $error");
      return false;
    });
  }

  //UPDATE PUSH TOKEN
  Future<dynamic> updateSearchRadius(int searchRadius,) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(Constants.appUser.userId)
    .update({
      'searchRadius': searchRadius,
     }).then((_) async {
      print("success!");
      Constants.appUser.searchRadius = searchRadius;
      await Constants.appUser.saveUserDetails();
      return true;
    }).catchError((error) {
      print("Failed to update: $error");
      return false;
    });
  }

  Future<dynamic> updateUserRating(double rating, AppUser user) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(user.userId)
    .update({
      'totalRating' : (user.totalRating + rating),
      'totalReviewsCount' : (user.totalReviewsCount + 1),
     }).then((_) async {
      print("success!");
      return true;
    }).catchError((error) {
      print("Failed to update: $error");
      return false;
    });
  }
}