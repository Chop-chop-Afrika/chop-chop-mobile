/// GET /referral/me — the code to share and the copy that goes with it.
class ReferralMeModel {
  bool? status;
  String? message;
  ReferralMe? data;

  ReferralMeModel({this.status, this.message, this.data});

  ReferralMeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ReferralMe.fromJson(json['data']) : null;
  }
}

class ReferralMe {
  String? referralCode;
  String? shareText;

  ReferralMe({this.referralCode, this.shareText});

  ReferralMe.fromJson(Map<String, dynamic> json) {
    referralCode = json['referralCode'];
    shareText = json['shareText'];
  }
}

/// GET /referral/invites — paginated list of people referred.
class ReferralInvitesModel {
  bool? status;
  String? message;
  List<ReferralInvite>? record;
  int? currentPage;
  bool? hasNextPage;

  ReferralInvitesModel({this.status, this.message, this.record});

  ReferralInvitesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final data = json['data'];
    if (data is Map) {
      final rows = data['record'];
      if (rows is List) {
        record = rows
            .map((v) => ReferralInvite.fromJson(Map<String, dynamic>.from(v)))
            .toList();
      }
      currentPage = data['currentPage'];
      hasNextPage = data['hasNextPage'] ?? false;
    }
  }
}

class ReferralInvite {
  String? id;
  String? email;

  /// The API returns a numeric status for the invitee's progress.
  int? status;
  String? createdAt;

  ReferralInvite({this.id, this.email, this.status});

  ReferralInvite.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    status = json['status'];
    createdAt = json['createdAt'];
  }

  /// First letter for the avatar circle, since the API gives no name.
  String get initial =>
      (email == null || email!.isEmpty) ? '?' : email![0].toUpperCase();

  /// Shown in place of a name, which the API does not provide.
  String get displayName => email ?? 'Invited friend';
}

/// GET /referral/rewards — returns a bare list, not a page.
class ReferralRewardsModel {
  bool? status;
  String? message;
  List<ReferralReward>? data;

  ReferralRewardsModel({this.status, this.message, this.data});

  ReferralRewardsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final rows = json['data'];
    if (rows is List) {
      data = rows
          .map((v) => ReferralReward.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
  }
}

class ReferralReward {
  String? id;
  String? referralsId;

  /// The reward amount, shown as XP in the UI.
  num? token;
  bool? claimed;
  String? createdAt;

  ReferralReward({this.id, this.token, this.claimed});

  ReferralReward.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referralsId = json['referralsId'];
    token = json['token'];
    claimed = json['claimed'];
    createdAt = json['createdAt'];
  }

  bool get isUnclaimed => claimed != true;
}
