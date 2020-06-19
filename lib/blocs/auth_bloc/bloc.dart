import 'package:asia/blocs/auth_bloc/events.dart';
import 'package:asia/blocs/auth_bloc/state.dart';
import 'package:asia/models/user.dart';
import 'package:asia/repository/authentication.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthenticationEvents, AuthenticationState> {
  @override
  AuthenticationState get initialState => UnAuthenticatedState();
  final authrepo = AuthRepo();
  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvents event) async* {
    if (event is VerifyPhoneNumberEvent) {
      authrepo.verifyPhoneNumber(
          phoneNumber: event.phoneNumber, callback: event.callback);
    } else if (event is CheckIfLoggedIn) {
      User user = await authrepo.checkIfUserLoggedIn();
      if (user != null) {
        yield AuthenticatedState(user: user);
      } else
        yield UnAuthenticatedState();
    } else if (event is VerifyOtpEvent) {
      var state, message;
      try {
        User user = await authrepo.signInWithSmsCode(event.otp);
        if (user != null) {
          state = AuthCallbackType.completed;
        } else {
          state = AuthCallbackType.failed;
        }
      } catch (e) {
        state = AuthCallbackType.failed;
        message = e.code;
      }
      event.callback(state, message);
    }
  }
}
