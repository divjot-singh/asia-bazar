import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/add_address/map_widget.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/secondary_button.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class AddAddress extends StatefulWidget {
  final bool first;
  final String addressType;
  AddAddress({this.first = false, this.addressType});
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
      BlocProvider.of<UserDatabaseBloc>(context)
          .add(AddUserAddress(address: address, callback: addAddressCallback));
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
                    addressType: widget.addressType,
                    disableSend: disableSend,
                    sendCallback: saveData,
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
