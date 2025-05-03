class User {
  final String userID;
  final String userMobile;
  late final String userName;
  final String profilePic;
  final bool isPremium;

  User(
      {required this.userMobile,
        required this.profilePic,
        required this.userName,
      required this.isPremium,required this.userID});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json["_id"],
      userMobile: json["user_mobile"],
      userName: json["user_name"],
      profilePic: json["profile_pic"],
      isPremium: json["is_premium"],
    );
  }
}
