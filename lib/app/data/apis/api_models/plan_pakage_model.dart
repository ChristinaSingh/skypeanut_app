class PlanPackagesModel {
  String? status;
  Packages? packages;

  PlanPackagesModel({this.status, this.packages});

  PlanPackagesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    packages = json['packages'] != null
        ? Packages.fromJson(json['packages'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (packages != null) {
      data['packages'] = packages!.toJson();
    }
    return data;
  }
}

class Packages {
  Starter10? starter10;
  Starter10? monthly50;
  Starter10? bulk100;

  Packages({this.starter10, this.monthly50, this.bulk100});

  Packages.fromJson(Map<String, dynamic> json) {
    starter10 = json['starter_10'] != null
        ? Starter10.fromJson(json['starter_10'])
        : null;
    monthly50 = json['monthly_50'] != null
        ? Starter10.fromJson(json['monthly_50'])
        : null;
    bulk100 = json['bulk_100'] != null
        ? Starter10.fromJson(json['bulk_100'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (starter10 != null) {
      data['starter_10'] = starter10!.toJson();
    }
    if (monthly50 != null) {
      data['monthly_50'] = monthly50!.toJson();
    }
    if (bulk100 != null) {
      data['bulk_100'] = bulk100!.toJson();
    }
    return data;
  }
}

class Starter10 {
  int? credits;
  int? priceCents;
  String? label;

  Starter10({this.credits, this.priceCents, this.label});

  Starter10.fromJson(Map<String, dynamic> json) {
    credits = json['credits'];
    priceCents = json['price_cents'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['credits'] = credits;
    data['price_cents'] = priceCents;
    data['label'] = label;
    return data;
  }
}
