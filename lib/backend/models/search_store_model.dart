class SearchStoreModel {
  bool? status;
  String? message;
  List<StoreModelData>? data;
  int? currentPage;
  int? totalPages;
  bool? hasNextPage;

  SearchStoreModel({this.status, this.message, this.data});

  SearchStoreModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    // /user/search returns a paginated object ({record, currentPage, ...}).
    // It used to be a bare list, and calling forEach on the object passed two
    // arguments to a one-argument callback, which threw
    // "(dynamic) => Null is not a subtype of (String, dynamic) => void".
    // Both shapes are accepted so an older deployment still works.
    final dynamic payload = json['data'];
    final dynamic rows = payload is Map ? payload['record'] : payload;
    if (rows is List) {
      data = rows
          .map((v) => StoreModelData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (payload is Map) {
      currentPage = (payload['currentPage'] as num?)?.toInt();
      totalPages = (payload['totalPages'] as num?)?.toInt();
      hasNextPage = payload['hasNextPage'] ?? false;
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

class StoreModelData {
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

  StoreModelData(
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
        this.status});

  StoreModelData.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}
