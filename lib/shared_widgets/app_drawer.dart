import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserDatabaseState appState =
        BlocProvider.of<UserDatabaseBloc>(context).state;
    Map user;
    if (appState is UserIsUser) {
      user = appState.user;
    } else if (appState is NewUser) {
      user = appState.user;
    }
    String username = user[KeyNames['userName']];
    ThemeData theme = Theme.of(context);
    return Drawer(
      child: Container(
        decoration: BoxDecoration(gradient: Gradients.lightPink),
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: ListTile(
                onTap: () {
                  print('hello');
                },
                title: Text(
                    L10n().getStr(
                      'drawer.hi',
                      {'name': username},
                    ),
                    style: theme.textTheme.h3
                        .copyWith(color: ColorShades.darkPink)),
                subtitle: username != null && username.length > 0
                    ? null
                    : Text(
                        L10n().getStr(
                          'drawer.editUsername',
                        ),
                        style: theme.textTheme.body1Regular
                            .copyWith(color: Color(0XFFee2644)),
                      ),
                trailing: username != null && username.length > 0
                    ? Icon(
                        Icons.keyboard_arrow_right,
                        color: ColorShades.darkPink,
                      )
                    : Icon(
                        Icons.edit,
                        color: ColorShades.darkPink,
                      ),
              ),
            ),
            ListTile(
              onTap: () {
                //Navigator.popAndPushNamed(context, Constants.ADD_ADDRESS);
              },
              title: Text(
                  L10n().getStr(
                    'drawer.addressList',
                  ),
                  style:
                      theme.textTheme.h3.copyWith(color: ColorShades.darkPink)),
            ),
            Divider(),
            ListTile(
              onTap: () {
                Navigator.popAndPushNamed(context, Constants.ADD_ADDRESS);
              },
              title: Text(
                  L10n().getStr(
                    'drawer.addAddress',
                  ),
                  style:
                      theme.textTheme.h3.copyWith(color: ColorShades.darkPink)),
            ),
            Divider(),
            ListTile(
              onTap: () {
                Utilities.logout(context);
              },
              title: Text(
                  L10n().getStr(
                    'drawer.logout',
                  ),
                  style: theme.textTheme.h3.copyWith(color: ColorShades.white)),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
