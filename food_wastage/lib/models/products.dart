// ignore_for_file: curly_braces_in_flow_control_structures

class Product {

  String productId = "";
  String productName = "";
  String productAreaLocality = "";
  String productAddedDate = "";
  double productLatitude = 0;
  double productLongitude = 0;
  String productOwnerName;
  String productOwnerId = "";
  String productImage ="";
  String productCategory = "";
  String productDescription = "";
  String productPrice = "";
  String productCondition = "";
  String productDelivery = "";
  String productExtra = "";
  int favoriteCount = 0;
  String distanceInKm = "";
  
  Product({this.productId = '', this.productName ='', this.productAreaLocality = '',  this.productAddedDate = "",  this.productLatitude = 0, this.productLongitude = 0, this.productOwnerName = '', this.productOwnerId = '', this.productImage = '', this.productCategory = "", this.productDescription = "", this.productPrice = "",this.productCondition = "",this.productDelivery = "",this.productExtra = "", this.favoriteCount = 0});
  
  factory Product.fromJson(dynamic json) {
    Product product =  Product(
      productId: '',
      productName: json['productName'],
      productAreaLocality : json['productAreaLocality'],
      productAddedDate: json['productAddedDate'].toDate().toString(),
      productLatitude: json['productLatitude'],
      productLongitude: json["productLongitude"],
      productOwnerName: json["productOwnerName"],
      productOwnerId: json['productOwnerId'],
      productImage: json["productPicture"],
      productCategory: json['productCategory'],
      productDescription : json['productDescription'],
      productPrice: json["productPrice"],
      productCondition: json['productCondition'],
      productDelivery : json['productDelivery'],
      productExtra : json['productExtra'],     
      favoriteCount : json['favoriteCount'] 
    );  
    return product;
  }
}