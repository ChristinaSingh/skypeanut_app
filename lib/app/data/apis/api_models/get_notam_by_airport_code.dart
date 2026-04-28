class NotamModel {
  bool? success;
  List<Data>? data;

  NotamModel({this.success, this.data});

  NotamModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? location;
  String? startTime;
  String? endTime;
  String? description;
  String? criticality;

  Data(
      {this.location,
        this.startTime,
        this.endTime,
        this.description,
        this.criticality});

  Data.fromJson(Map<String, dynamic> json) {
    location = json['location'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    description = json['description'];
    criticality = json['criticality'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['description'] = description;
    data['criticality'] = criticality;
    return data;
  }
}
