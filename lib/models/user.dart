class User {
  final String userId;
  final String userName;
  final String phoneNumber;
  final Map cart;
  String firebaseToken;

  User(
      {this.userId,
      this.userName,
      this.phoneNumber,
      this.firebaseToken,
      this.cart});

  Map<String, dynamic> getInfo() {
    return {
      "userId": userId,
      "userName": userName,
      "phoneNumber": phoneNumber,
      "firebaseToken": firebaseToken,
      "cart": cart,
    };
  }
}
