class GetProfileModel {
  String? status;
  int? userId;
  String? fullName;
  String? email;
  String? profilePhotoUrl;
  bool? isActive;

  GetProfileModel(
      {this.status,
        this.userId,
        this.fullName,
        this.email,
        this.profilePhotoUrl,
        this.isActive});

  GetProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    userId = json['user_id'];
    fullName = json['full_name'];
    email = json['email'];
    profilePhotoUrl = json['profile_photo_url'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['user_id'] = userId;
    data['full_name'] = fullName;
    data['email'] = email;
    data['profile_photo_url'] = profilePhotoUrl;
    data['is_active'] = isActive;
    return data;
  }
}
