import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/add_address/map_widget.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  ThemeData theme;
  String username;
  bool disableSend = false;
  var key = GlobalKey<FormState>();
  FocusNode _usernameInput = FocusNode();
  addAddressCallback(bool result) {
    Navigator.pop(context);
    if (result) {
      Navigator.pushReplacementNamed(context, Constants.HOME);
    } else {
      showCustomSnackbar(
          type: SnackbarType.error,
          context: context,
          content: L10n().getStr('profile.address.error'));
      setState(() {
        disableSend = false;
      });
    }
  }

  saveData(Map address) {
    if (key.currentState.validate() && address != null) {
      address['is_default'] = true;
      setState(() {
        disableSend = true;
      });
      BlocProvider.of<UserDatabaseBloc>(context).add(OnboardUser(
          username: username, address: address, callback: addAddressCallback));
      showCustomLoader(context);
    } else if (!key.currentState.validate()) {
      _usernameInput.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    var ctaWidget = Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
          boxShadow: disableSend ? null : [Shadows.inputLight],
          shape: BoxShape.circle,
          color: disableSend ? ColorShades.grey200 : ColorShades.greenBg),
      child: Center(
        child: Icon(
          Icons.keyboard_arrow_right,
          color: ColorShades.white,
          size: 32,
        ),
      ),
    );
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('onboarding.title'),
          hideBackArrow: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(Spacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(L10n().getStr('onboarding.name'),
                    style: theme.textTheme.h3
                        .copyWith(color: ColorShades.bastille)),
                SizedBox(
                  height: Spacing.space12,
                ),
                Form(
                  key: key,
                  child: InputBox(
                    onChanged: (value) {
                      username = value.trim();
                    },
                    focusNode: _usernameInput,
                    hintText: L10n().getStr('onboarding.name.hint'),
                    hideShadow: true,
                    validator: (value) {
                      value = value.trim();
                      if (value.length == 0) {
                        return L10n().getStr('onboarding.name.error');
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: Spacing.space20,
                ),
                Text(L10n().getStr('onboarding.message'),
                    style: theme.textTheme.h3
                        .copyWith(color: ColorShades.bastille)),
                SizedBox(
                  height: Spacing.space12,
                ),
                MapWidget(
                  height: 300,
                  disableSend: disableSend,
                  sendCallback: saveData,
                  ctaText: L10n().getStr('onboarding.cta.title'),
                  ctaWidget: ctaWidget,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
