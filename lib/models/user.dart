class User {
  final String userId;
  final String userName;
  final String phoneNumber;
  String firebaseToken;

  User({
    this.userId,
    this.userName,
    this.phoneNumber,
    this.firebaseToken,
  });

  Map<String, String> getInfo() {
    return {
      "userId": userId,
      "userName": userName,
      "phoneNumber": phoneNumber,
      "firebaseToken": firebaseToken,
    };
  }
}
