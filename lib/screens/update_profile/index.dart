import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/address_list/index.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia/theme/style.dart';

class UpdateProfile extends StatefulWidget {
  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  bool nameEditable = false;
  GlobalKey key = GlobalKey<FormState>();
  String username, phone;
  Map defaultAddress;
  List<Widget> getAddressBox() {
    ThemeData theme = Theme.of(context);
    if (defaultAddress != null) {
      return [
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(L10n().getStr('editProfile.defaultAddress'),
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg)),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Constants.ADDRESS_LIST);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      L10n().getStr('editProfile.more'),
                      style: theme.textTheme.body2Regular
                          .copyWith(color: ColorShades.greenBg),
                    ),
                    SizedBox(
                      width: Spacing.space4,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: ColorShades.greenBg,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: Spacing.space12,
        ),
        getAddressCard(
            context: context, address: defaultAddress, hideOptions: true),
      ].toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          setState(() {
            nameEditable = false;
          });
        },
        child: Scaffold(
          appBar: MyAppBar(
            hasTransparentBackground: true,
            title: L10n().getStr('editProfile.profile'),
          ),
          body: BlocBuilder<UserDatabaseBloc, Map>(
            builder: (context, currentState) {
              var userState = currentState['userstate'];
              username = userState.user[KeyNames['userName']];
              phone = userState.user[KeyNames['phone']];
              var addressList = userState.user['address'];
              if (addressList is List) {
                defaultAddress = addressList
                    .firstWhere((item) => item['is_default'] == true);
              }
              return Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Spacing.space16, vertical: Spacing.space20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(L10n().getStr('editProfile.username'),
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                    SizedBox(
                      height: Spacing.space12,
                    ),
                    nameEditable
                        ? Form(
                            key: key,
                            child: InputBox(
                              onChanged: (value) {
                                username = value.trim();
                              },
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  showCustomLoader(context);
                                  BlocProvider.of<UserDatabaseBloc>(context)
                                      .add(UpdateUsername(
                                          username: username,
                                          callback: (_) {
                                            Navigator.pop(context);
                                            setState(() {
                                              nameEditable = false;
                                            });
                                          }));
                                },
                                child: Icon(
                                  Icons.check,
                                  color: ColorShades.greenBg,
                                  size: 20,
                                ),
                              ),
                              value: username,
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
                          )
                        : Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  username,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.body1Regular
                                      .copyWith(color: ColorShades.bastille),
                                ),
                              ),
                              SizedBox(
                                width: Spacing.space8,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    nameEditable = true;
                                  });
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: ColorShades.greenBg,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                    SizedBox(
                      height: Spacing.space20,
                    ),
                    Text(L10n().getStr('editProfile.phone'),
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                    SizedBox(
                      height: Spacing.space12,
                    ),
                    InputBox(
                      disabled: true,
                      onChanged: (value) {
                        phone = value.trim();
                      },
                      value: phone,
                      hideShadow: true,
                    ),
                    SizedBox(
                      height: Spacing.space20,
                    ),
                    ...getAddressBox(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
