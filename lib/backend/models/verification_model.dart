class VerificationModel {
  bool? status;
  String? message;
  String? accessToken;
  String? refreshToken;
  String? refreshTokenExpiresIn;
  String? accessTokenExpiresIn;

  VerificationModel(
      {this.status,
        this.message,
        this.accessToken,
        this.refreshToken,
        this.refreshTokenExpiresIn,
        this.accessTokenExpiresIn});

  VerificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    refreshTokenExpiresIn = json['refreshTokenExpiresIn'];
    accessTokenExpiresIn = json['accessTokenExpiresIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['refreshTokenExpiresIn'] = this.refreshTokenExpiresIn;
    data['accessTokenExpiresIn'] = this.accessTokenExpiresIn;
    return data;
  }
}
