import 'package:asia/repository/authentication.dart';
import 'package:flutter/foundation.dart';

abstract class AuthenticationEvents {}

class VerifyPhoneNumberEvent extends AuthenticationEvents {
  final String phoneNumber;
  final Function callback;
  VerifyPhoneNumberEvent({@required this.phoneNumber, @required this.callback});
}

class VerifyOtpEvent extends AuthenticationEvents {
  final String otp;
  final Function callback;
  VerifyOtpEvent({@required this.otp, @required this.callback});
}

class CheckIfLoggedIn extends AuthenticationEvents {}

class SetState extends AuthenticationEvents {
  final AuthCallbackType callbackType;
  SetState({@required this.callbackType});
}

class SignOut extends AuthenticationEvents {
  final Function callback;
  SignOut({this.callback});
}
