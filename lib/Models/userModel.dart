// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  bool error;
  String message;
  String accountType;
  User user;

  UserModel({
    required this.error,
    required this.message,
    required this.accountType,
    required this.user,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    error: json["error"],
    message: json["message"],
    accountType: json["accountType"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "accountType": accountType,
    "user": user.toJson(),
  };
}

class User {
  String position;
  String email;
  String fullName;
  String mobile;
  int staffId;

  User({
    required this.position,
    required this.email,
    required this.fullName,
    required this.mobile,
    required this.staffId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    position: json["position"],
    email: json["email"],
    fullName: json["full_name"],
    mobile: json["mobile"],
    staffId: json["staff_id"],
  );

  Map<String, dynamic> toJson() => {
    "position": position,
    "email": email,
    "full_name": fullName,
    "mobile": mobile,
    "staff_id": staffId,
  };
}
