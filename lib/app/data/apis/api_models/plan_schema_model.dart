class PlanSchemaModel {
  String? status;
  String? message;
  Schema? schema;

  PlanSchemaModel({this.status, this.message, this.schema});

  PlanSchemaModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    schema =
    json['schema'] != null ? Schema.fromJson(json['schema']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (schema != null) {
      data['schema'] = schema!.toJson();
    }
    return data;
  }
}

class Schema {
  int? basicAlert;
  int? hazardDetail;
  int? flightPlan;

  Schema({this.basicAlert, this.hazardDetail, this.flightPlan});

  Schema.fromJson(Map<String, dynamic> json) {
    basicAlert = json['basic_alert'];
    hazardDetail = json['hazard_detail'];
    flightPlan = json['flight_plan'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['basic_alert'] = basicAlert;
    data['hazard_detail'] = hazardDetail;
    data['flight_plan'] = flightPlan;
    return data;
  }
}
