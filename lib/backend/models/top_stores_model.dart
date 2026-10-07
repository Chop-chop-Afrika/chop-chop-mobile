class TopStoresModel {
  bool? status;
  String? message;
  List<TopStoresData>? data;

  TopStoresModel({this.status, this.message, this.data});

  TopStoresModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <TopStoresData>[];
      json['data'].forEach((v) {
        data!.add(new TopStoresData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TopStoresData {
  String? id;
  String? name;
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
  double? averageRating;
  int? totalRatings;
  double? distance;

  TopStoresData(
      {this.id,
        this.name,
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
        this.averageRating,
        this.totalRatings,
        this.distance});

  TopStoresData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
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
    averageRating = (json['averageRating'] as num?)?.toDouble();
    totalRatings = json['totalRatings'];
    distance = (json['distance'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
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
    data['averageRating'] = this.averageRating;
    data['totalRatings'] = this.totalRatings;
    data['distance'] = this.distance;
    return data;
  }
}
