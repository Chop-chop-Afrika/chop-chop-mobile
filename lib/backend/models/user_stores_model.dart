class UserStoresModel {
  bool? status;
  String? message;
  Data? data;

  UserStoresModel({this.status, this.message, this.data});

  UserStoresModel.fromJson(Map<String, dynamic> json) {
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
  int? currentPage;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPrevPage;
  int? nextPage;
  int? prevPage;
  List<Record>? record;

  Data(
      {this.currentPage,
        this.totalPages,
        this.hasNextPage,
        this.hasPrevPage,
        this.nextPage,
        this.prevPage,
        this.record});

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    totalPages = (json['totalPages'] as num?)?.toInt();
    hasNextPage = json['hasNextPage'];
    hasPrevPage = json['hasPrevPage'];
    nextPage = json['nextPage'];
    prevPage = json['prevPage'];
    if (json['record'] != null) {
      record = <Record>[];
      json['record'].forEach((v) {
        record!.add(new Record.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    data['hasNextPage'] = this.hasNextPage;
    data['hasPrevPage'] = this.hasPrevPage;
    data['nextPage'] = this.nextPage;
    data['prevPage'] = this.prevPage;
    if (this.record != null) {
      data['record'] = this.record!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Record {
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
  double? distance;

  Record(
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
        this.distance});

  Record.fromJson(Map<String, dynamic> json) {
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
    distance = (json['distance'] as num?)?.toDouble();
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
    data['distance'] = this.distance;
    return data;
  }
}
