class CurrentAddressModel {
  bool? status;
  String? message;
  CurrentAddressInfo? data;

  CurrentAddressModel({this.status, this.message, this.data});

  CurrentAddressModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new CurrentAddressInfo.fromJson(json['data']) : null;
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

class CurrentAddressInfo {
  String? address;
  double? latitude;
  double? longitude;

  CurrentAddressInfo({this.address, this.latitude, this.longitude});

  CurrentAddressInfo.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
