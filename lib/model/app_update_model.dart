import 'dart:convert';

AppUpdateModel appUpdateModelFromJson(String str) => AppUpdateModel.fromJson(json.decode(str));

String appUpdateModelToJson(AppUpdateModel data) => json.encode(data.toJson());

class AppUpdateModel {
  bool? success;
  Data? data;

  AppUpdateModel({
    this.success,
    this.data,
  });

  factory AppUpdateModel.fromJson(Map<String, dynamic> json) => AppUpdateModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  int? id;
  String? appVersion;
  int? showPopUp;
  String? storeLink;

  Data({
    this.id,
    this.appVersion,
    this.showPopUp,
    this.storeLink,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    appVersion: json["appVersion"],
    showPopUp: json["showPopUp"],
    storeLink: json["storeLink"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "appVersion": appVersion,
    "showPopUp": showPopUp,
    "storeLink": storeLink,
  };
}
