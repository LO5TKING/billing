// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  int? userId;
  String? companyName;
  String? personName;
  String? mobileNo;
  String? emailId;
  String? shopNo;
  String? street;
  String? area;
  String? city;
  String? state;
  String? country;
  String? gstNo;
  String? signU;
  String? photo;
  DateTime? createdDate;
  DateTime? modifiedDate;
  int? deviceLimit;
  bool? status;
  String? clientId;
  dynamic password;

  LoginResponseModel({
    this.userId,
    this.companyName,
    this.personName,
    this.mobileNo,
    this.emailId,
    this.shopNo,
    this.street,
    this.area,
    this.city,
    this.state,
    this.country,
    this.gstNo,
    this.signU,
    this.photo,
    this.createdDate,
    this.modifiedDate,
    this.deviceLimit,
    this.status,
    this.clientId,
    this.password,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    userId: json["userId"],
    companyName: json["companyName"],
    personName: json["personName"],
    mobileNo: json["mobileNo"],
    emailId: json["emailId"],
    shopNo: json["shopNo"],
    street: json["street"],
    area: json["area"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    gstNo: json["gstNo"],
    signU: json["signU"],
    photo: json["photo"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    modifiedDate: json["modifiedDate"] == null ? null : DateTime.parse(json["modifiedDate"]),
    deviceLimit: json["deviceLimit"],
    status: json["status"],
    clientId: json["clientId"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "companyName": companyName,
    "personName": personName,
    "mobileNo": mobileNo,
    "emailId": emailId,
    "shopNo": shopNo,
    "street": street,
    "area": area,
    "city": city,
    "state": state,
    "country": country,
    "gstNo": gstNo,
    "signU": signU,
    "photo": photo,
    "createdDate": createdDate?.toIso8601String(),
    "modifiedDate": modifiedDate?.toIso8601String(),
    "deviceLimit": deviceLimit,
    "status": status,
    "clientId": clientId,
    "password": password,
  };
}
