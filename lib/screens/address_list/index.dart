import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia/theme/style.dart';

class AddressList extends StatefulWidget {
  final bool selectView;
  AddressList({this.selectView = false});
  @override
  _AddressListState createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: L10n().getStr('drawer.addressList'),
          hasTransparentBackground: true,
        ),
        body: BlocBuilder<UserDatabaseBloc, Map>(
          builder: (context, currentState) {
            var userState = currentState['userstate'];
            List addressList;
            if (userState is UserIsUser) {
              addressList = userState.user[KeyNames['address']];
              addressList.sort((item1, item2) {
                if (item1['is_default'] == true)
                  return -1;
                else if (item2['is_default'] == true)
                  return 1;
                else
                  return 0;
              });
            }
            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Spacing.space16, vertical: Spacing.space24),
              child: ListView.builder(
                itemCount: addressList.length,
                itemBuilder: (context, index) {
                  var address = addressList[index];
                  return getAddressCard(address: address, context: context);
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, Constants.ADD_ADDRESS);
          },
          child: Icon(
            Icons.add,
            color: ColorShades.white,
          ),
          backgroundColor: ColorShades.greenBg,
        ),
      ),
    );
  }
}

Widget getAddressCard(
    {@required Map address,
    @required BuildContext context,
    bool hideOptions = false}) {
  ThemeData theme = Theme.of(context);
  var icon;
  if (address['type'] == 'home') {
    icon = Icons.home;
  } else if (address['type'] == 'work') {
    icon = Icons.work;
  } else if (address['type'] == 'other') {
    icon = Icons.location_on;
  }
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [ColorShades.lightGreenBg50, ColorShades.greenBg]),
      borderRadius: BorderRadius.circular(20),
    ),
    padding: EdgeInsets.only(
        left: Spacing.space16,
        right: Spacing.space16,
        top: Spacing.space12,
        bottom: Spacing.space28),
    margin: EdgeInsets.only(bottom: Spacing.space16),
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  color: ColorShades.white,
                ),
                SizedBox(
                  width: Spacing.space8,
                ),
                SizedBox(
                  width: Spacing.space4,
                ),
                Text(
                  L10n().getStr('profile.address.type.' + address['type']),
                  style: theme.textTheme.h4.copyWith(color: ColorShades.white),
                ),
                if (address['is_default'] == true)
                  SizedBox(
                    width: Spacing.space4,
                  ),
                if (address['is_default'] == true)
                  Text(
                    '(' + L10n().getStr('address.default') + ')',
                    style: theme.textTheme.body2Italic
                        .copyWith(color: ColorShades.white),
                  ),
              ],
            ),
            if (!hideOptions)
              PopupMenuTheme(
                data: PopupMenuThemeData(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: theme.textTheme.body1Regular
                        .copyWith(color: ColorShades.white)),
                child: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.pushNamed(context, Constants.ADD_ADDRESS,
                          arguments: {'address': address, 'isEdit': true});
                    } else if (value == 'delete') {
                      showDialog(
                          context: context,
                          child: Container(
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              actionsPadding: EdgeInsets.symmetric(
                                  horizontal: Spacing.space16),
                              content: Text(
                                L10n().getStr('address.delete.confirmation'),
                                style: theme.textTheme.h4
                                    .copyWith(color: ColorShades.redOrange),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      L10n().getStr('confirmation.cancel'),
                                      style: theme.textTheme.body1Regular
                                          .copyWith(color: ColorShades.grey300),
                                    )),
                                PrimaryButton(
                                  text: L10n().getStr('confirmation.delete'),
                                  onPressed: () {
                                    showCustomLoader(context);
                                    BlocProvider.of<UserDatabaseBloc>(context)
                                        .add(DeleteUserAddress(
                                            timestamp:
                                                address['timestamp'].toString(),
                                            callback: (_) {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }));
                                  },
                                )
                              ],
                            ),
                          ));
                    } else if (value == 'set_default') {
                      showCustomLoader(context);
                      BlocProvider.of<UserDatabaseBloc>(context)
                          .add(SetDefaultAddress(
                              timestamp: address['timestamp'].toString(),
                              callback: (_) {
                                Navigator.pop(context);
                              }));
                    }
                  },
                  padding: EdgeInsets.all(0),
                  icon: Icon(
                    Icons.more_horiz,
                    color: ColorShades.white,
                    size: 32,
                  ),
                  itemBuilder: (context) {
                    var list = List<PopupMenuEntry<Object>>();
                    if (address['is_default'] != true)
                      list.add(
                        PopupMenuItem(
                          value: 'set_default',
                          child: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.settings,
                                color: ColorShades.greenBg,
                                size: 16,
                              ),
                              label: Text(
                                L10n().getStr('address.setDefault'),
                                style: theme.textTheme.body2Regular
                                    .copyWith(color: ColorShades.greenBg),
                              )),
                        ),
                      );
                    if (address['is_default'] != true)
                      list.add(PopupMenuDivider(
                        height: 2,
                      ));
                    list.add(
                      PopupMenuItem(
                        value: 'edit',
                        textStyle: theme.textTheme.body1Regular
                            .copyWith(color: theme.colorScheme.textPrimaryDark),
                        child: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.edit,
                              color: ColorShades.greenBg,
                              size: 16,
                            ),
                            label: Text(
                              L10n().getStr('address.edit'),
                              style: theme.textTheme.body2Regular
                                  .copyWith(color: ColorShades.greenBg),
                            )),
                      ),
                    );
                    if (address['is_default'] != true)
                      list.add(PopupMenuDivider(
                        height: 2,
                      ));
                    if (address['is_default'] != true)
                      list.add(
                        PopupMenuItem(
                          value: 'delete',
                          textStyle: theme.textTheme.body1Regular.copyWith(
                              color: theme.colorScheme.textPrimaryDark),
                          child: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.delete,
                                color: ColorShades.greenBg,
                                size: 16,
                              ),
                              label: Text(
                                L10n().getStr('address.delete'),
                                style: theme.textTheme.body2Regular
                                    .copyWith(color: ColorShades.greenBg),
                              )),
                        ),
                      );
                    return list;
                  },
                ),
              )
          ],
        ),
        SizedBox(
          height: Spacing.space12,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 36),
          child: Text(
            address['address_text'],
            style:
                theme.textTheme.body1Regular.copyWith(color: ColorShades.white),
          ),
        ),
      ],
    ),
  );
}
