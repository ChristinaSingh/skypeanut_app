class ReferralModel {
  String? status;
  String? referralCode;
  int? referralCredits;
  var creditsExpiresAt;
  int? pendingReferrerAwards;
  int? referredCount;
  int? totalCreditsLeft;
  List<String>? referredUsers;
  int? monthlyReferred;
  int? monthlyLimit;
  int? monthlyRemaining;

  ReferralModel(
      {this.status,
        this.referralCode,
        this.referralCredits,
        this.creditsExpiresAt,
        this.pendingReferrerAwards,
        this.referredCount,
        this.referredUsers,
        this.monthlyReferred,
        this.monthlyLimit,
        this.monthlyRemaining});

  ReferralModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    referralCode = json['referral_code'];
    referralCredits = json['referral_credits'];
    creditsExpiresAt = json['credits_expires_at'];
    pendingReferrerAwards = json['pending_referrer_awards'];
    totalCreditsLeft = json['total_credits_left'];
    referredUsers = json['referred_users'].cast<String>();
    monthlyReferred = json['monthly_referred'];
    monthlyLimit = json['monthly_limit'];
    monthlyRemaining = json['monthly_remaining'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['referral_code'] = referralCode;
    data['referral_credits'] = referralCredits;
    data['credits_expires_at'] = creditsExpiresAt;
    data['pending_referrer_awards'] = pendingReferrerAwards;
    data['referred_count'] = referredCount;
    data['referred_users'] = referredUsers;
    data['monthly_referred'] = monthlyReferred;
    data['total_credits_left'] = totalCreditsLeft;
    data['monthly_limit'] = monthlyLimit;
    data['monthly_remaining'] = monthlyRemaining;
    return data;
  }
}
