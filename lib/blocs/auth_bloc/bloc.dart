import 'package:asia/blocs/auth_bloc/events.dart';
import 'package:asia/blocs/auth_bloc/state.dart';
import 'package:asia/models/user.dart';
import 'package:asia/repository/authentication.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthenticationEvents, AuthenticationState> {
  AuthBloc(AuthenticationState initialState) : super(initialState);

  @override
  AuthenticationState get initialState => UnAuthenticatedState();
  final authrepo = AuthRepo();
  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvents event) async* {
    if (event is VerifyPhoneNumberEvent) {
      yield FetchingState();
      authrepo.verifyPhoneNumber(
          phoneNumber: event.phoneNumber, callback: event.callback);
    } else if (event is CheckIfLoggedIn) {
      yield FetchingState();
      User user = await authrepo.checkIfUserLoggedIn();
      if (user != null) {
        yield AuthenticatedState(user: user);
      } else
        yield UnAuthenticatedState();
    } else if (event is VerifyOtpEvent) {
      var state, message;
      try {
        yield FetchingState();
        User user = await authrepo.signInWithSmsCode(event.otp);
        if (user != null) {
          state = AuthCallbackType.completed;
        } else {
          state = AuthCallbackType.failed;
        }
      } catch (e) {
        state = AuthCallbackType.failed;
        message = e;
      }
      event.callback(state, message);
    } else if (event is SetState) {
      if (event.callbackType == AuthCallbackType.codeSent) {
        yield OtpSentState();
      } else if (event.callbackType == AuthCallbackType.failed) {
        yield UnAuthenticatedState();
      }
    } else if (event is SignOut) {
      await authrepo.signout();
      if (event.callback != null) {
        event.callback();
      }
      yield UnAuthenticatedState();
    }
  }
}
