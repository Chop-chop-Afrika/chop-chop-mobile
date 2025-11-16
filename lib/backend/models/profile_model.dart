class ProfileModel {
  bool? status;
  String? message;
  ProfileData? data;

  ProfileModel({this.status, this.message, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new ProfileData.fromJson(json['data']) : null;
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

class ProfileData {
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? phone;
  String? dob;
  dynamic avatar;
  int? wallet;
  String? referralCode;
  String? createdAt;

  ProfileData(
      {this.id,
        this.email,
        this.firstName,
        this.lastName,
        this.phone,
        this.dob,
        this.avatar,
        this.wallet,
        this.referralCode,
        this.createdAt});

  ProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
    dob = json['dob'];
    avatar = json['avatar'];
    wallet = json['wallet'];
    referralCode = json['referralCode'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['phone'] = this.phone;
    data['dob'] = this.dob;
    data['avatar'] = this.avatar;
    data['wallet'] = this.wallet;
    data['referralCode'] = this.referralCode;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
