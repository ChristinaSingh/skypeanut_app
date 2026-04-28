class LoginModel {
  String? status;
  String? message;
  int? id;
  int? userId;
  String? email;
  String? resetToken;

  LoginModel(
      {this.status,
        this.message,
        this.id,
        this.userId,
        this.email,
        this.resetToken});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    id = json['id'];
    userId = json['user_id'];
    email = json['email'];
    resetToken = json['reset_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['id'] = id;
    data['user_id'] = userId;
    data['email'] = email;
    data['reset_token'] = resetToken;
    return data;
  }
}
