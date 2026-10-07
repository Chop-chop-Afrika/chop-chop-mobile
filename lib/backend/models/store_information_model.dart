class StoreInformationModel {
  bool? status;
  String? message;
  Data? data;

  StoreInformationModel({this.status, this.message, this.data});

  StoreInformationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  String? userId;
  String? name;
  String? email;
  String? phone;
  String? logo;
  String? location;
  double? longitude;
  double? latitude;
  String? deliveryTime;
  String? openTime;
  String? closeTime;
  String? type;
  String? createdAt;
  String? updatedAt;
  int? status;
  User? user;
  double? averageRating;
  int? totalRatings;

  Data(
      {this.id,
        this.userId,
        this.name,
        this.email,
        this.phone,
        this.logo,
        this.location,
        this.longitude,
        this.latitude,
        this.deliveryTime,
        this.openTime,
        this.closeTime,
        this.type,
        this.createdAt,
        this.updatedAt,
        this.status,
        this.user,
        this.averageRating,
        this.totalRatings});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    logo = json['logo'];
    location = json['location'];
    longitude = (json['longitude'] as num?)?.toDouble();
    latitude = (json['latitude'] as num?)?.toDouble();
    deliveryTime = json['delivery_time'];
    openTime = json['open_time'];
    closeTime = json['close_time'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    status = json['status'];
    user = json['User'] != null ? new User.fromJson(json['User']) : null;
    averageRating = (json['averageRating'] as num?)?.toDouble();
    totalRatings = json['totalRatings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['logo'] = this.logo;
    data['location'] = this.location;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['delivery_time'] = this.deliveryTime;
    data['open_time'] = this.openTime;
    data['close_time'] = this.closeTime;
    data['type'] = this.type;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['status'] = this.status;
    if (this.user != null) {
      data['User'] = this.user!.toJson();
    }
    data['averageRating'] = this.averageRating;
    data['totalRatings'] = this.totalRatings;
    return data;
  }
}

class User {
  String? firstName;
  String? lastName;
  String? phone;

  User({this.firstName, this.lastName, this.phone});

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['phone'] = this.phone;
    return data;
  }
}
