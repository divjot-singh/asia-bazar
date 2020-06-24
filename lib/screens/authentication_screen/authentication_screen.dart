import 'package:asia/blocs/auth_bloc/bloc.dart';
import 'package:asia/blocs/auth_bloc/events.dart';
import 'package:asia/blocs/auth_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/repository/authentication.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/utilities.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart' as pc;

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String _dropDownValue = '+', phoneNumber = '', otpValue = '';
  TextEditingController _dropDownController;
  bool disableSend = false;
  bool isCodeSent = false;
  FocusNode _focusNodeCountryCode = FocusNode(), _focusNodePhone = FocusNode();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _dropDownController = TextEditingController();

    BlocProvider.of<AuthBloc>(context).add(CheckIfLoggedIn());
    getCountryCode();
    super.initState();
  }

  alreadyLoggedIn() {
    Navigator.pushReplacementNamed(
        context, Constants.POST_AUTHENTICATION_REDIRECTOR);
  }

  verifyPhoneNumberCallback(authenticationState, [data]) {
    if (authenticationState == AuthCallbackType.completed) {
      alreadyLoggedIn();
    } else if (authenticationState == AuthCallbackType.codeSent) {
      setState(() {
        isCodeSent = true;
      });
      BlocProvider.of<AuthBloc>(context)
          .add(SetState(callbackType: authenticationState));
    } else if (authenticationState == AuthCallbackType.failed) {
      String message = L10n().getStr('phoneAuthentication.verificationFailed');

      if (data != null && data.code != null && data.code != 'firebaseAuth') {
        message = L10n().getStr('error.' + data.code);
      }
      setState(() {
        disableSend = false;
      });
      if (!isCodeSent) {
        isCodeSent = false;
        resetForm();
      }
      if (isCodeSent) {
        BlocProvider.of<AuthBloc>(context)
            .add(SetState(callbackType: AuthCallbackType.codeSent));
      } else
        BlocProvider.of<AuthBloc>(context)
            .add(SetState(callbackType: authenticationState));
      showCustomSnackbar(
        type: SnackbarType.error,
        context: context,
        content: message,
      );
    }
  }

  sendOtp() {
    BlocProvider.of<AuthBloc>(context).add(VerifyPhoneNumberEvent(
        phoneNumber: _dropDownValue + phoneNumber,
        callback: verifyPhoneNumberCallback));
  }

  resetForm() {
    BlocProvider.of<AuthBloc>(context)
        .add(SetState(callbackType: AuthCallbackType.failed));
    setState(() {
      disableSend = false;
      isCodeSent = false;
    });
  }

  submitOtp(otp) {
    if (otpValue.isEmpty ||
        int.tryParse(otpValue) == null ||
        otpValue.length < 6) {
      showCustomSnackbar(
          type: SnackbarType.error,
          context: context,
          content: L10n().getStr('error.ERROR_INVALID_VERIFICATION_CODE'));
    } else {
      BlocProvider.of<AuthBloc>(context).add(
          VerifyOtpEvent(otp: otpValue, callback: verifyPhoneNumberCallback));
    }
  }

  getCountryCode() async {
    try {
      String countrycode = await FlutterSimCountryCode.simCountryCode;
      Map dialCode = Countries.firstWhere(
          (item) => item['code'].toLowerCase() == countrycode.toLowerCase());
      _dropDownValue = dialCode['dial_code'];
      _dropDownController.text = _dropDownValue;
      _focusNodePhone.requestFocus();
    } catch (e) {
      _dropDownController.text = '+';
      _focusNodeCountryCode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    bool _isLoading() {
      return BlocProvider.of<AuthBloc>(context).state is FetchingState;
    }

    double viewportHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).viewInsets.bottom;
    bool _keyboardIsVisible = Utilities.keyboardIsVisible(context);
    Widget otpScreen() {
      ThemeData theme = Theme.of(context);
      return Container(
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
        child: Column(
          mainAxisAlignment: _keyboardIsVisible
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: <Widget>[
            Text(
              L10n().getStr('phoneAuthentication.enterCode',
                  {'number': _dropDownValue + ' ' + phoneNumber}),
              textAlign: TextAlign.center,
              style: theme.textTheme.pageTitle.copyWith(
                  color: theme.colorScheme.textPrimaryLight,
                  fontWeight: FontWeight.normal),
            ),
            SizedBox(
              height: Spacing.space32,
            ),
            PinCodeTextField(
              textInputType: TextInputType.number,
              autoDismissKeyboard: true,
              autoFocus: true,
              length: 6,
              obsecureText: false,
              textStyle: theme.textTheme.formFieldText.copyWith(
                color: theme.colorScheme.textPrimaryLight,
              ),
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 40,
                fieldWidth: 40,
                borderWidth: 1,
                activeFillColor: ColorShades.darkGreenBg,
                inactiveFillColor: ColorShades.darkGreenBg,
                selectedFillColor: Colors.white,
                activeColor: ColorShades.greenBg,
                inactiveColor: ColorShades.greenBg,
                selectedColor: ColorShades.darkGreenBg,
              ),
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              onCompleted: (otpValue) {
                submitOtp(otpValue);
              },
              onChanged: (value) {
                setState(() {
                  otpValue = value;
                });
              },
              beforeTextPaste: (text) {
                print('jee');
                if (text.length > 6 || int.parse(text) == null) {
                  return false;
                }
                return true;
              },
            ),
            SizedBox(
              height: Spacing.space32,
            ),
            RichText(
              text: TextSpan(
                  text: L10n().getStr(
                    'phoneAuthentication.error.didntGetCode',
                  ),
                  style: theme.textTheme.body1Regular
                      .copyWith(color: ColorShades.white),
                  children: [
                    TextSpan(text: '. '),
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            sendOtp();
                          },
                        text: L10n().getStr('phoneAuthentication.resend'),
                        style: theme.textTheme.body1Bold.copyWith(
                            color: Color(0xffF89938),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline))
                  ]),
            ),
          ],
        ),
      );
    }

    Widget unAuthenticatedScreen() {
      return Container(
        child: Column(
          mainAxisAlignment: _keyboardIsVisible
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: <Widget>[
            Text(
              L10n().getStr('authentication.enterNumber'),
              style: theme.textTheme.h3.copyWith(
                color: theme.colorScheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: _keyboardIsVisible ? Spacing.space24 : 60,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.space24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 75,
                    child: InputBox(
                      controller: _dropDownController,
                      keyboardType: TextInputType.phone,
                      keyboardAppearance: Brightness.light,
                      maxLength: 4,
                      focusNode: _focusNodeCountryCode,
                      hintText: 'XXX',
                      autovalidate: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return '';
                        }
                        if (value.length > 4) {
                          return '';
                        }

                        return null;
                      },
                      onChanged: (String newValue) {
                        _dropDownValue = newValue;
                        if (newValue.length == 0) {
                          _dropDownController.text = '+';
                          _dropDownValue = '+';
                          _dropDownController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: _dropDownController.text.length));
                        }
                        if (newValue.length == 2) {
                          _focusNodePhone.requestFocus();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: Spacing.space12,
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: InputBox(
                        onChanged: (value) {
                          phoneNumber = value;
                        },
                        focusNode: _focusNodePhone,
                        keyboardType: TextInputType.phone,
                        keyboardAppearance: Brightness.light,
                        hintText: 'XXXXX XXXXX',
                        validator: (value) {
                          print('validator');
                          if (value.length > 0 && int.tryParse(value) == null ||
                              value.length < 6 ||
                              value.length > 14) {
                            return L10n().getStr(
                              "phoneAuthentication.invalidPhoneNumber",
                            );
                          }

                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: _keyboardIsVisible ? Spacing.space24 : 40,
            ),
            GestureDetector(
              onTap: () {
                var result = _formKey.currentState.validate();
                if (!result && !disableSend) {
                  _focusNodePhone.requestFocus();
                } else {
                  sendOtp();
                }
              },
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                    boxShadow: [Shadows.input],
                    shape: BoxShape.circle,
                    color:
                        disableSend ? ColorShades.grey200 : ColorShades.white),
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_right,
                    color: ColorShades.greenBg,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return BlocListener<AuthBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          alreadyLoggedIn();
        }
      },
      child: SafeArea(
        child: Material(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: _keyboardIsVisible
                  ? Gradients.greenGradientReverse
                  : Gradients.greenGradient,
            ),
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: _keyboardIsVisible
                          ? viewportHeight / 3
                          : viewportHeight / 2,
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: _keyboardIsVisible ? 0 : 60),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.space20,
                                  ),
                                  child: Image.asset(
                                    'assets/images/home_logo.png',
                                    height: _keyboardIsVisible ? 200 : 250,
                                    width: _keyboardIsVisible ? 200 : 250,
                                  ),
                                ),
                              ),
                            ),
                            if (isCodeSent)
                              Positioned(
                                top: 20,
                                left: 0,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      resetForm();
                                    },
                                    color: _keyboardIsVisible
                                        ? ColorShades.white
                                        : ColorShades.greenBg,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      constraints:
                          BoxConstraints(minHeight: viewportHeight / 2),
                      padding: EdgeInsets.symmetric(
                          horizontal: Spacing.space16,
                          vertical: Spacing.space12),
                      child: Center(
                        child: BlocBuilder<AuthBloc, AuthenticationState>(
                            builder: (context, currentState) {
                          if (currentState is UnAuthenticatedState) {
                            return unAuthenticatedScreen();
                          } else if (currentState is OtpSentState) {
                            return otpScreen();
                          } else if (currentState is FetchingState) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: Spacing.space32),
                              child: PageFetchingView(),
                            );
                          }
                          return Container();
                        }),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // child: CustomScrollView(
            //   shrinkWrap: false,
            //   slivers: <Widget>[
            //     SliverToBoxAdapter(
            //       child: Stack(
            //         children: <Widget>[
            //           Align(
            //             alignment: Alignment.topCenter,
            //             child: Padding(
            //               padding:
            //                   EdgeInsets.only(top: _keyboardIsVisible ? 0 : 60),
            //               child: Container(
            //                 padding: EdgeInsets.symmetric(
            //                   horizontal: Spacing.space20,
            //                 ),
            //                 child: Image.asset(
            //                   'assets/images/home_logo.png',
            //                   height: _keyboardIsVisible ? 200 : 250,
            //                   width: _keyboardIsVisible ? 200 : 250,
            //                 ),
            //               ),
            //             ),
            //           ),
            //           if (isCodeSent)
            //             Positioned(
            //               top: 20,
            //               left: 0,
            //               child: Container(
            //                 height: 50,
            //                 width: 50,
            //                 child: IconButton(
            //                   icon: Icon(Icons.arrow_back),
            //                   onPressed: () {
            //                     resetForm();
            //                   },
            //                   color: _keyboardIsVisible
            //                       ? ColorShades.white
            //                       : ColorShades.pinkBackground,
            //                 ),
            //               ),
            //             )
            //         ],
            //       ),
            //     ),
            //     SliverFillRemaining(
            //       hasScrollBody: false,
            //       child: Container(
            //         padding: EdgeInsets.symmetric(
            //             vertical: Spacing.space8, horizontal: Spacing.space16),
            //         child: Column(
            //           mainAxisSize: MainAxisSize.max,
            //           children: <Widget>[
            //             BlocBuilder<AuthBloc, AuthenticationState>(
            //                 builder: (context, currentState) {
            //               if (currentState is UnAuthenticatedState) {
            //                 return unAuthenticatedScreen();
            //               } else if (currentState is OtpSentState) {
            //                 return otpScreen();
            //               } else if (currentState is FetchingState) {
            //                 return Padding(
            //                   padding: EdgeInsets.symmetric(
            //                       vertical: Spacing.space32),
            //                   child: PageFetchingView(),
            //                 );
            //               }
            //               return Container();
            //             }),
            //           ],
            //         ),
            //       ),
            //     )
            //   ],
            // ),
          ),
        ),
      ),
    );
  }
}
