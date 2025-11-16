class AddressSearchModel {
  bool? status;
  String? message;
  List<SearchedAddress>? data;

  AddressSearchModel({this.status, this.message, this.data});

  AddressSearchModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SearchedAddress>[];
      json['data'].forEach((v) {
        data!.add(new SearchedAddress.fromJson(v));
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

class SearchedAddress {
  String? placeId;
  String? description;
  String? mainText;
  String? secondaryText;

  SearchedAddress({this.placeId, this.description, this.mainText, this.secondaryText});

  SearchedAddress.fromJson(Map<String, dynamic> json) {
    placeId = json['placeId'];
    description = json['description'];
    mainText = json['mainText'];
    secondaryText = json['secondaryText'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['placeId'] = this.placeId;
    data['description'] = this.description;
    data['mainText'] = this.mainText;
    data['secondaryText'] = this.secondaryText;
    return data;
  }
}
