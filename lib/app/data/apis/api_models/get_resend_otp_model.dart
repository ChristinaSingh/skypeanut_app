class ResentOtpModel {
  String? message;
  bool? success;

  ResentOtpModel({this.message, this.success});

  ResentOtpModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['success'] = success;
    return data;
  }
}
