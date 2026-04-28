class VerifyModel {
  String? message;
  String? success;
  String? token;
  User? user;

  VerifyModel({this.message, this.success, this.token, this.user});

  VerifyModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['success'] = success;
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? email;
  String? fullName;
  String? id;

  User({this.email, this.fullName, this.id});

  User.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    fullName = json['full_name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['full_name'] = fullName;
    data['id'] = id;
    return data;
  }
}
