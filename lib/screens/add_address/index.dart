import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/add_address/map_widget.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddAddress extends StatefulWidget {
  final bool first, isEdit;
  final Map address;
  AddAddress({this.first = false, this.isEdit = false, this.address});
  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  bool disableSend = false;

  addAddressCallback(bool result) {
    Navigator.pop(context);
    dynamic snackbarResult;
    if (result) {
      snackbarResult = showCustomSnackbar(
          type: SnackbarType.success,
          context: context,
          content: L10n().getStr('profile.address.added'));
      snackbarResult.then((_) {
        if (widget.first == true)
          Navigator.pushReplacementNamed(context, Constants.HOME);
        else
          Navigator.pop(context);
      });
    } else {
      snackbarResult = showCustomSnackbar(
          type: SnackbarType.error,
          context: context,
          content: L10n().getStr('profile.address.error'));
      setState(() {
        disableSend = false;
      });
    }
  }

  saveData(Map address) {
    if (address != null) {
      setState(() {
        disableSend = true;
      });
      if (widget.isEdit == true) {
        if (widget.address['is_default'] == true) {
          address['is_default'] = true;
        }
        BlocProvider.of<UserDatabaseBloc>(context).add(UpdateUserAddress(
            address: address,
            timestamp: widget.address['timestamp'].toString(),
            callback: addAddressCallback));
      } else {
        BlocProvider.of<UserDatabaseBloc>(context).add(
            AddUserAddress(address: address, callback: addAddressCallback));
      }
      showCustomLoader(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: ColorShades.white,
          appBar: MyAppBar(
            title: L10n().getStr('drawer.addAddress'),
            textColor: ColorShades.greenBg,
            hasTransparentBackground: true,
            hideBackArrow: widget.first,
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: MapWidget(
                    disableSend: disableSend,
                    sendCallback: saveData,
                    isEdit: widget.isEdit,
                    addressType: widget.address!= null ? widget.address['type'] : null,
                    selectedLocation: widget.isEdit == true
                        ? {
                            'latitude': widget.address['lat'],
                            'longitude': widget.address['long']
                          }
                        : null,
                    ctaText: widget.isEdit == true
                        ? L10n().getStr('address.updateLocation')
                        : null,
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
