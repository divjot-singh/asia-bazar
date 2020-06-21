import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/l10n/l10n.dart';
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
  AddAddress({this.first = false});
  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  GoogleMapController mapController;
  bool disableSend = false;
  Location location = Location();
  Geolocator locator = Geolocator();
  LocationData currentPosition =
      LocationData.fromMap({'latitude': 20, 'longitude': 77});
  Marker marker;
  GlobalKey key = GlobalKey();
  bool showLoader = true;
  FocusNode _focusNode = FocusNode();
  TextEditingController addressController = TextEditingController(text: '');
  Set<Marker> markerSet;
  @override
  void initState() {
    getCurrentLocation();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Scrollable.ensureVisible(key.currentContext,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
      }
    });
    super.initState();
  }

  getCurrentLocation() async {
    var position = await location.getLocation();

    setState(() {
      currentPosition = position;
      showLoader = false;
      markerSet = addMarker(
          LatLng(currentPosition.latitude, currentPosition.longitude));
    });
  }

  Set<Marker> addMarker(LatLng position) {
    return <Marker>[
      Marker(
        markerId: MarkerId('current_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarker,
      ),
    ].toSet();
  }

  String getAddressFromPlacemark(List<Placemark> placemarks) {
    Placemark placeMark = placemarks[0];
    String name = placeMark.name.length > 0 ? placeMark.name + ',' : '';
    String subLocality =
        placeMark.subLocality.length > 0 ? placeMark.subLocality + ',' : '';
    String locality =
        placeMark.locality.length > 0 ? placeMark.locality + ',' : '';
    String administrativeArea = placeMark.administrativeArea.length > 0
        ? placeMark.administrativeArea + ','
        : '';
    String postalCode =
        placeMark.postalCode.length > 0 ? placeMark.postalCode + ',' : '';
    String country = placeMark.country;
    String address =
        "$name $subLocality $locality $administrativeArea $postalCode $country";
    return address;
  }

  Widget _mapWidget() {
    return GoogleMap(
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      markers: markerSet,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 20,
      ),
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
      onCameraMove: (CameraPosition position) {
        setState(() {
          markerSet = addMarker(position.target);
        });
      },
      onCameraIdle: () async {
        var marker = markerSet.first;
        var position = marker.position;

        List<Placemark> placemarks = await locator.placemarkFromCoordinates(
            position.latitude, position.longitude);
        String address = getAddressFromPlacemark(placemarks);
        setState(() {
          addressController.text = address;
        });
      },
      onTap: (location) {
        if (_focusNode.hasFocus)
          FocusScope.of(context).requestFocus(new FocusNode());
        else
          setState(() {
            markerSet = addMarker(location);
          });
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                colors: [ColorShades.darkPink, ColorShades.white])),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: MyAppBar(
              title: L10n().getStr('profile.address.select'),
              textColor: ColorShades.darkPink,
              hasTransparentBackground: true,
              hideBackArrow: widget.first,
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: showLoader ? TinyLoader() : _mapWidget()),
                    SizedBox(
                      height: Spacing.space20,
                    ),
                    Container(
                      key: key,
                      padding: EdgeInsets.symmetric(
                          vertical: Spacing.space12,
                          horizontal: Spacing.space16),
                      child: InputBox(
                        disabled: addressController.text.length == 0,
                        controller: addressController,
                        focusNode: _focusNode,
                        onChanged: (_) {},
                        maxLines: 2,
                        hintText: '',
                      ),
                    )
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: Spacing.space16,
                    left: Spacing.space24,
                    right: Spacing.space24),
                child: SecondaryButton(
                  disabled: disableSend,
                  noWidth: true,
                  onPressed: () {
                    var position = markerSet.first.position;
                    Map address = {
                      'lat': position.latitude,
                      'long': position.longitude,
                      'address_text': addressController.text,
                      'is_default': true
                    };
                    if (!disableSend) {
                      BlocProvider.of<UserDatabaseBloc>(context).add(
                          AddUserAddress(
                              address: address, callback: addAddressCallback));
                      showCustomLoader(context);
                    }
                    setState(() {
                      disableSend = true;
                    });
                  },
                  text: L10n().getStr('profile.address.addAddress'),
                ),
              ),
            )),
      ),
    );
  }
}
