// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import '../models/appuser.dart';
import '../models/products.dart';
import '../utils/constants.dart';

class AppController {

  final firestoreInstance = FirebaseFirestore.instance;

  //SIGN UP
  Future signUpUser(String userName, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.user?.uid);
      AppUser newUser = AppUser(
        userId: userCredential.user!.uid,
        userEmail: email,
        userName: userName,
      );
      dynamic resultUser = await newUser.signUpUser(newUser);
      if (resultUser != null) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['User'] = resultUser;
        Constants.appUser = resultUser;
        await Constants.appUser.saveUserDetails();
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] ="User cannot signup at this time. Try again later";
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        finalResponse['ErrorMessage'] = "No user found for that email";
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        finalResponse['ErrorMessage'] = "Wrong password provided for that user";
      }
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  //SIGN IN
  Future signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print(userCredential.user!.uid);
       AppUser newUser = AppUser(
        userId: userCredential.user!.uid,
        userEmail: email,
        userName: '',
      );
      dynamic resultUser = await AppUser.getLoggedInUserDetail(newUser);
      if (resultUser != null)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['User'] = resultUser;
        Constants.appUser = resultUser;
        await Constants.appUser.saveUserDetails();
        return finalResponse;
      }
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "User cannot login at this time. Try again later";
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        finalResponse['ErrorMessage'] = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        finalResponse['ErrorMessage'] =
            "The account already exists for that email";
      } else {
        finalResponse['ErrorMessage'] = e.code;
      }
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }
  
  //FORGOT PASSWORD
  Future forgotPassword(String email) async {
    try {
      String result = "";
      await FirebaseAuth.instance
      .sendPasswordResetEmail(email: email).then((_) async {
        result = "Success";
      }).catchError((error) {
        result = error.toString();
        print("Failed emailed : $error");
      });

      if (result == "Success") {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = result;
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      finalResponse['ErrorMessage'] = e.code;
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future<String> uploadFile(File uploadImage) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + basename(uploadImage.path);
    final firebaseStorage = FirebaseStorage.instance;
    //Upload to Firebase
    var snapshot = await firebaseStorage.ref().child("profile_pictures").child(fileName).putFile(File(uploadImage.path));
    var downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  //UPDATE PUSH TOKEN
  Future<dynamic> updateOneSignalUserID(String oneSignalUserID) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(Constants.appUser.userId)
    .update({
      "oneSignalUserId": oneSignalUserID
     }).then((_) async {
      print("success!");
      Constants.appUser.oneSignalUserID = oneSignalUserID;
      AppUser.saveOneSignalUserId(oneSignalUserID);
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }

  Future<dynamic> updateProfileInfo(String userName, String photoUrl) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(Constants.appUser.userId)
    .update({
      'userName': userName,
      'userPicture': photoUrl,
     }).then((_) async {
      print("success!");
      Constants.appUser.userName = userName;
      Constants.appUser.userPicture = photoUrl;
      await Constants.appUser.saveUserDetails();
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }

  Future getAddressDetail(double latitude, double longitude) async {
    try {
      var url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyCDJrAl-UkLdqgVIbw7weRpmID_uzXhIp4';
      final Uri _uri = Uri.parse(url);
      Response response = await get(_uri,);     
      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        dynamic resultDetail = (data['results'].isEmpty) ? {} : data['results'][0];
        String locality = "";
        if(resultDetail.isNotEmpty)
        {
          List addresses = resultDetail['address_components'];
          for(int i=0; i < addresses.length; i++)
          {
            if(addresses[i]['types'].contains('administrative_area_level_3'))
              locality = addresses[i]['long_name'];
          }
        }
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['Locality'] = locality;
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future getAllProducts() async {
    try {
      List<Product> allProducts = [];
      final firestoreInstance = FirebaseFirestore.instance;
      dynamic result = await firestoreInstance.collection("products").get()
      .then((value) {
        for (var result in value.docs)
        {
          Map prodData = result.data();
          Product prod = Product.fromJson(prodData);
          prod.productId =  result.id;
          double distanceInMeters = Geolocator.distanceBetween(Constants.latitude, Constants.longitude, prod.productLatitude, prod.productLongitude);
          double distanceInKm = distanceInMeters/1000;
          prod.distanceInKm = distanceInKm.toStringAsFixed(1);
          if(distanceInKm <= Constants.appUser.searchRadius.toDouble())
            allProducts.add(prod);
        }
        return true;
      });
      
      if (result) 
      {
        if(allProducts.length>1) //SORT BY TIME
          allProducts.sort((b, a) => a.productAddedDate.compareTo(b.productAddedDate));
        
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['AllProducts'] = allProducts;
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    }
    catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future getAllCategoryProducts(String selectedCategory) async {
    try {
      List<Product> allProducts = [];
      final firestoreInstance = FirebaseFirestore.instance;
      dynamic result = await firestoreInstance.collection("products")
      .where('productCategory', isEqualTo: selectedCategory)
      .get()
      .then((value) {
        for (var result in value.docs)
        {
          Map prodData = result.data();
          Product prod = Product.fromJson(prodData);
          prod.productId =  result.id;
          double distanceInMeters = Geolocator.distanceBetween(Constants.latitude, Constants.longitude, prod.productLatitude, prod.productLongitude);
          double distanceInKm = distanceInMeters/1000;
          prod.distanceInKm = distanceInKm.toStringAsFixed(1);
          if(distanceInKm <= Constants.appUser.searchRadius.toDouble())
            allProducts.add(prod);
        }
        return true;
      });
      
      if (result) 
      {
        if(allProducts.length>1) //SORT BY TIME
          allProducts.sort((b, a) => a.productAddedDate.compareTo(b.productAddedDate));
        
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['CategoryProducts'] = allProducts;
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    }
    catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future getUserListedProducts(String userId) async {
    try {
      List<Product> allProducts = [];
      final firestoreInstance = FirebaseFirestore.instance;
      dynamic result = await firestoreInstance.collection("products")
      .where('productOwnerId', isEqualTo: userId)
      .get()
      .then((value) {
        for (var result in value.docs)
        {
          Map prodData = result.data();
          Product prod = Product.fromJson(prodData);
          prod.productId =  result.id;
          allProducts.add(prod);
        }
        return true;
      });
      
      if (result) 
      {
        if(allProducts.length>1) //SORT BY TIME
          allProducts.sort((b, a) => a.productAddedDate.compareTo(b.productAddedDate));
        
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['MyProducts'] = allProducts;
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    }
    catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }


  Future addProductPressed(String productTitle, String productCategory, String productPrice, String productDescription, String productCondition, String productDelivery, String productAge, String productExtra, File prodPicture, LatLng productCoordinates) async {
    try {
      // GeoData data = await Geocoder2.getDataFromCoordinates(
      //   latitude: productCoordinates.latitude,
      //   longitude: productCoordinates.longitude,
      //   googleMapApiKey: "AIzaSyCDJrAl-UkLdqgVIbw7weRpmID_uzXhIp4"
      // );
      //RESIZE IMAGES IF BIGGER THEN 1MB
      List productImages = [];
      File? productPicture = await Constants.resizePhotoIfBiggerThen1mb(prodPicture);
      //UPLOAD ON FIREBASE
      String userImage1FirebasePath  = await uploadFile(productPicture);
      //
      String productExtaValue = (productAge.isNotEmpty) ? productAge : productExtra;
      dynamic result = await FirebaseFirestore.instance.collection("products").
      add({
        'productName' : productTitle,
        'productDescription': productDescription,
        'productCategory': productCategory,
        'productPrice': productPrice,
        'productCondition': productCondition,
        'productDelivery': productDelivery,
        'productExtra': productExtaValue,
        'productPicture': userImage1FirebasePath,
        'productAreaLocality': 'Test Address',
        'productLatitude': productCoordinates.latitude,
        'productLongitude': productCoordinates.longitude,
        'productOwnerName': Constants.appUser.userName,
        'productOwnerId': Constants.appUser.userId,
        'favoriteCount': 0,
        'productAddedDate' : FieldValue.serverTimestamp()
      }).then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
      });

      if (result) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  //FAVORITES
  Future addProductFavorite(Product product) async {
    try {
      dynamic result = await FirebaseFirestore.instance.collection("favorites").
      add({
        'productId' : product.productId,
        'productName' : product.productName,
        'productPicture': product.productImage,
        'productAreaLocality': 'Test Address',
        'favoriteByUserName': Constants.appUser.userEmail,
        'favoriteByUserId': Constants.appUser.userId,
        'favAddedDate' : FieldValue.serverTimestamp()
      }).then((_) async {
        print("success!");
        await updateProductFavorite(product, true);
        Constants.appUser.myFavorites.add(product.productId);
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
      });

      if (result) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future updateProductFavorite(Product product, bool increaseCount) async {
    try {
      dynamic result = await FirebaseFirestore.instance.collection("products").doc(product.productId)
      .update({
        'favoriteCount': (increaseCount) ? (product.favoriteCount + 1) : (product.favoriteCount - 1),
      }).then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
      });

      if (result) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future getAllMyFavoriteProducts() async {
    try {
      final firestoreInstance = FirebaseFirestore.instance;
      dynamic result = await firestoreInstance.collection("favorites")
      .where('favoriteByUserId', isEqualTo: Constants.appUser.userId)
      .get()
      .then((value) {
        for (var result in value.docs)
        {
          Map favData = result.data();
          Constants.appUser.myFavorites.add(favData['productId']);
        }
        return true;
      });
      
      if (result) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    }
    catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future removeProductFavorite(Product product) async {
    try {
      String favDocId = "";
      dynamic result = await FirebaseFirestore.instance.collection("favorites")
      .where('productId', isEqualTo: product.productId)
      .where('favoriteByUserId', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
        for (var result in value.docs) {
          print(result.data);
          Map favData = result.data();
          favDocId = result.id;
          print(favDocId);
        }
        return true;
      });

      if(favDocId.isNotEmpty)
      {
        await FirebaseFirestore.instance.collection("favorites").
          doc(favDocId).delete().then((_) async {
          print("success!");
          Constants.appUser.myFavorites.remove(product.productId);
          updateProductFavorite(product,false);
          return true;
        }).catchError((error) {
          print("Failed to update: $error");
          return false;
        });
        
      }

      if (result) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future getMyFavoriteProducts() async {
    try {
      List<Product> allProducts = [];
      final firestoreInstance = FirebaseFirestore.instance;
      for(int i=0; i < Constants.appUser.myFavorites.length; i++)
      {
        await firestoreInstance.collection("products")
        .doc(Constants.appUser.myFavorites[i])
        .get()
        .then((value) {
          Map prodData = value.data()!;
          Product prod = Product.fromJson(prodData);
          prod.productId =  value.id;
          double distanceInMeters = Geolocator.distanceBetween(Constants.latitude, Constants.longitude, prod.productLatitude, prod.productLongitude);
          double distanceInKm = distanceInMeters/1000;
          prod.distanceInKm = distanceInKm.toStringAsFixed(1);
          allProducts.add(prod);
        });
      }
      
      if(allProducts.length>1) //SORT BY TIME
        allProducts.sort((b, a) => a.productAddedDate.compareTo(b.productAddedDate));
      
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      finalResponse['MyProducts'] = allProducts;
      return finalResponse;
    }
    catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future reportProduct(Product product, String reportReaon) async {
    try {   
      dynamic result = await firestoreInstance.collection("reported_products").add({
        'productId': product.productId,
        'productName': product.productName,
        'productOwnerId' : product.productOwnerId,
        'productOwnerName' : product.productOwnerName,
        'reportedById': Constants.appUser.userId,
        'reportedByEmail': Constants.appUser.userEmail,
        'reportedReason': reportReaon,
        'reportedProductTime' : FieldValue.serverTimestamp()
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
      });
      
      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future reportComment(Map commentDetail, String reportReaon) async {
    try {   
      dynamic result = await firestoreInstance.collection("reported_reviews").add({
        'commentId': commentDetail['commentId'],
        'comment': commentDetail['comment'],
        'commentRating' : commentDetail['rating'],
        'commentDoneById' : commentDetail['reviewedByUserId'],
        'commentDoneByEmail' : commentDetail['reviewedByUserEmail'],
        'reportedById': Constants.appUser.userId,
        'reportedByEmail': Constants.appUser.userEmail,
        'reportedReason': reportReaon,
        'reportedCommentTime' : FieldValue.serverTimestamp(),
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
      });
      
      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future addUserReview(String comment, double rating, AppUser reviewedUser) async {
    try {
      dynamic result = await FirebaseFirestore.instance.collection("reviews").
      add({
        'comment' : comment,
        'rating': rating,
        'reviewedUserId': reviewedUser.userId,
        'reviewedUserEmail': reviewedUser.userEmail,
        'reviewedByUserId': Constants.appUser.userId,
        'reviewedByUserEmail': Constants.appUser.userEmail,
        'reviewedByUserName': Constants.appUser.userName,
        'reviewedByPhotoUrl': Constants.appUser.userPicture,
        'reviewAddedDate' : FieldValue.serverTimestamp()
      }).then((_) async {
        print("success!");
        AppUser().updateUserRating(rating, reviewedUser);
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
      });

      if (result) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future getAllMyReviews(List allReviews, String userId) async {
    try {
      dynamic result = await firestoreInstance.collection("reviews")
      .where('reviewedUserId', isEqualTo: userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['commentId'] = result.id;
          allReviews.add(taskData);
        });
        return true;
      });

      if (result)
      {
        allReviews.sort((a, b) => a['reviewAddedDate'].toDate().compareTo(b['reviewAddedDate'].toDate()));
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future sendChatNotificationToUser(AppUser user) async {
    try {
      Map<String, String> requestHeaders = {
        "Content-type": "application/json", 
        "Authorization" : "Basic ${Constants.oneSignalRestKey}"
      };

      //if(user.oneSignalUserId.isEmpty)
      user = await AppUser.getUserDetailByUserId(user.userId);
      var url = 'https://onesignal.com/api/v1/notifications';
      final Uri _uri = Uri.parse(url);
      //String json = '{ "include_player_ids" : ["${user.oneSignalUserID}"], "app_id" : "${Constants.oneSignalId}", "small_icon" : "app_icon", "headings" : {"en" : "New Message"}, "contents" : {"en" : "You have a message from ${Constants.appUser.fullName}"}, "data" : { "userID" : "${Constants.appUser.userID}" } }';
      String json = '{ "include_player_ids" : ["${user.oneSignalUserID}"] ,"app_id" : "${Constants.oneSignalId}", "small_icon" : "app_icon", "headings" : {"en" : "New Request"},"contents" : {"en" : "You have received a request message from ${Constants.appUser.userName}"}}';
      Response response = await post(_uri, headers: requestHeaders, body: json);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    
      if (response.statusCode == 200) {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future deleteProduct(Product product) async {
    try {
      dynamic result =  await FirebaseFirestore.instance.collection("products").
      doc(product.productId).delete().then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
      });

      if (result) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Map setUpFailure() {
    Map finalResponse = <dynamic, dynamic>{}; //empty map
    finalResponse['Status'] = "Error";
    finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
    return finalResponse;
  }
}
