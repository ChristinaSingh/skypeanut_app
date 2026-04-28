class PaymentsCreateModel {
  String? status;
  String? message;
  int? paymentId;

  PaymentsCreateModel({this.status, this.message, this.paymentId});

  PaymentsCreateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    paymentId = json['payment_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['payment_id'] = paymentId;
    return data;
  }
}
