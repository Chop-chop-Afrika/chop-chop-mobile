class PlaceDetailsByIdModel {
  bool? status;
  String? message;
  Data? data;

  PlaceDetailsByIdModel({this.status, this.message, this.data});

  PlaceDetailsByIdModel.fromJson(Map<String, dynamic> json) {
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
  String? address;
  String? name;
  double? latitude;
  double? longitude;

  Data({this.address, this.name, this.latitude, this.longitude});

  Data.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['name'] = this.name;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
