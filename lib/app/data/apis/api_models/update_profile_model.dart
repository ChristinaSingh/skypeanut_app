class ProfileUpdateModel {
  String? status;
  String? message;
  int? userId;
  String? fullName;
  String? email;
  String? profilePhotoUrl;

  ProfileUpdateModel(
      {this.status,
        this.message,
        this.userId,
        this.fullName,
        this.email,
        this.profilePhotoUrl});

  ProfileUpdateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userId = json['user_id'];
    fullName = json['full_name'];
    email = json['email'];
    profilePhotoUrl = json['profile_photo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['user_id'] = userId;
    data['full_name'] = fullName;
    data['email'] = email;
    data['profile_photo_url'] = profilePhotoUrl;
    return data;
  }
}
