import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Drawer(
      child: BlocBuilder<UserDatabaseBloc, Map>(
        builder: (context, currentState) {
          var appState = currentState['userstate'];
          Map user;
          if (appState is UserIsUser) {
            user = appState.user;
          }
          String username = user[KeyNames['userName']];
          return Container(
            color: ColorShades.lightGreenBg,
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: ColorShades.greenBg, width: 1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/home_logo.png',
                        height: 70,
                        width: 70,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.popAndPushNamed(
                              context, Constants.EDIT_PROFILE);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                L10n().getStr(
                                  'drawer.hi',
                                  {'name': username},
                                ),
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.h3
                                    .copyWith(color: ColorShades.greenBg),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: ColorShades.greenBg,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Spacing.space12,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.popAndPushNamed(context, Constants.HOME);
                  },
                  leading: Icon(Icons.home, color: ColorShades.greenBg),
                  title: Text(
                      L10n().getStr(
                        'home.title',
                      ),
                      style: theme.textTheme.h4
                          .copyWith(color: ColorShades.greenBg)),
                ),
                Divider(
                  color: ColorShades.greenBg,
                  thickness: 1,
                ),
                ListTile(
                  onTap: () {
                    Navigator.popAndPushNamed(context, Constants.CART);
                  },
                  leading:
                      Icon(Icons.shopping_cart, color: ColorShades.greenBg),
                  title: Text(
                      L10n().getStr(
                        'drawer.cart',
                      ),
                      style: theme.textTheme.h4
                          .copyWith(color: ColorShades.greenBg)),
                ),
                Divider(
                  color: ColorShades.greenBg,
                  thickness: 1,
                ),
                ListTile(
                  onTap: () {
                    Navigator.popAndPushNamed(context, Constants.ORDER_LIST);
                  },
                  leading: Padding(
                    padding: EdgeInsets.only(left: Spacing.space4),
                    child: SvgPicture.asset(
                      'assets/images/invoice.svg',
                      color: ColorShades.greenBg,
                      width: 16,
                    ),
                  ),
                  title: Text(
                      L10n().getStr(
                        'drawer.orders',
                      ),
                      style: theme.textTheme.h4
                          .copyWith(color: ColorShades.greenBg)),
                ),
                Divider(
                  color: ColorShades.greenBg,
                  thickness: 1,
                ),
                ListTile(
                  onTap: () {
                    Navigator.popAndPushNamed(context, Constants.ADDRESS_LIST);
                  },
                  leading: Icon(Icons.location_on, color: ColorShades.greenBg),
                  title: Text(
                      L10n().getStr(
                        'drawer.addressList',
                      ),
                      style: theme.textTheme.h4
                          .copyWith(color: ColorShades.greenBg)),
                ),
                Divider(
                  color: ColorShades.greenBg,
                  thickness: 1,
                ),
                ListTile(
                  onTap: () {
                    Navigator.popAndPushNamed(context, Constants.ADD_ADDRESS);
                  },
                  leading: Icon(Icons.add_location, color: ColorShades.greenBg),
                  title: Text(
                      L10n().getStr(
                        'drawer.addAddress',
                      ),
                      style: theme.textTheme.h4
                          .copyWith(color: ColorShades.greenBg)),
                ),
                Divider(
                  color: ColorShades.greenBg,
                  thickness: 1,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.only(bottom: Spacing.space24),
                      child: ListTile(
                        onTap: () {
                          Utilities.logout(context);
                        },
                        leading: Padding(
                          padding:
                              EdgeInsets.only(left: Spacing.space8, top: 6),
                          child: SvgPicture.asset(
                            'assets/images/logout.svg',
                            color: ColorShades.greenBg,
                            height: 16,
                          ),
                        ),
                        title: Text(
                            L10n().getStr(
                              'drawer.logout',
                            ),
                            style: theme.textTheme.h3
                                .copyWith(color: ColorShades.greenBg)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
