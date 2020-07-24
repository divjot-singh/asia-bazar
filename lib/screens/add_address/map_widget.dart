import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/shared_widgets/secondary_button.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/navigator_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  final double height;
  final String ctaText, addressType;
  final bool disableSend;
  final Function sendCallback;
  final Widget ctaWidget;
  final bool isEdit;
  final Map selectedLocation;
  MapWidget(
      {this.height,
      this.ctaText,
      this.isEdit = false,
      this.disableSend = false,
      this.addressType,
      this.selectedLocation,
      this.ctaWidget,
      this.sendCallback});
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with WidgetsBindingObserver {
  GoogleMapController mapController;
  Location location = Location();
  Geolocator locator = Geolocator();
  LocationData currentPosition =
      LocationData.fromMap({'latitude': 20, 'longitude': 77});
  Marker marker;
  bool _serviceEnabled;
  String addressType;
  GlobalKey key = GlobalKey();
  bool showLoader = true, showMapError = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController addressController = TextEditingController(text: '');
  Set<Marker> markerSet;
  @override
  void initState() {
    addressType = widget.addressType != null ? widget.addressType : 'home';
    currentPosition = LocationData.fromMap({'latitude': 20, 'longitude': 77});
    WidgetsBinding.instance.addObserver(this);
    if (widget.selectedLocation != null) {
      currentPosition = LocationData.fromMap({...widget.selectedLocation});
      showLoader = false;
      markerSet = addMarker(
          LatLng(currentPosition.latitude, currentPosition.longitude));
    } else {
      getCurrentLocation();
    }
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Scrollable.ensureVisible(key.currentContext,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
      }
    });
    super.initState();
  }

  changeType(type) {
    setState(() {
      addressType = type;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.selectedLocation == null) {
      getCurrentLocation();
    }
  }

  getCurrentLocation() async {
    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          showlocationErrorDialog('SERVICE_STATUS_DISABLED');
          return;
        }
      }

      var permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.deniedForever) {
        var permission = await location.requestPermission();
        if (permission == PermissionStatus.denied) {
          showlocationErrorDialog('PERMISSION_DENIED');
          return;
        } else if (permission == PermissionStatus.deniedForever) {
          showlocationErrorDialog('PERMISSION_DENIED_NEVER_ASK');
          return;
        }
      }

      var position = await location.getLocation();
      print(position);
      setState(() {
        currentPosition = position;
        showLoader = false;
        showMapError = false;
        markerSet = addMarker(
            LatLng(currentPosition.latitude, currentPosition.longitude));
      });
    } catch (e) {
      print(e);
      showCustomSnackbar(
          context: context,
          content: L10n().getStr('profile.address.error'),
          type: SnackbarType.error);
    }
  }

  showlocationErrorDialog(error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: ColorShades.red,
        content: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: <Widget>[
            Text(
              L10n().getStr(
                "error.$error",
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body1Bold.copyWith(
                  color: Theme.of(context).colorScheme.textPrimaryLight,
                  decoration: TextDecoration.none),
            ),
            Padding(
              padding: EdgeInsets.only(top: Spacing.space16),
              child: PrimaryButton(
                text: L10n().getStr('redirector.goBack'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        showMapError = true;
      });
    });
  }

  sendData() {
    var position = markerSet.first.position;
    Map address = {
      'lat': position.latitude,
      'long': position.longitude,
      'address_text': addressController.text,
      'type': addressType,
    };
    if (!widget.disableSend) {
      widget.sendCallback(address);
    }
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
    String thoroughfare =
        placeMark.thoroughfare.length > 0 ? placeMark.thoroughfare + ',' : '';
    String locality =
        placeMark.locality.length > 0 ? placeMark.locality + ',' : '';
    String administrativeArea = placeMark.administrativeArea.length > 0
        ? placeMark.administrativeArea + ','
        : '';
    String postalCode =
        placeMark.postalCode.length > 0 ? placeMark.postalCode + ',' : '';
    String country = placeMark.country;
    String address =
        "$name $subLocality $thoroughfare $locality $administrativeArea $postalCode $country";
    return address;
  }

  Widget _mapWidget() {
    return GoogleMap(
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      markers: markerSet,
      mapType: MapType.normal,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
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
        try {
          List<Placemark> placemarks = await locator.placemarkFromCoordinates(
              position.latitude, position.longitude);
          String address = getAddressFromPlacemark(placemarks);
          setState(() {
            addressController.text = address;
          });
        } catch (e) {
          print(e);
          showCustomSnackbar(
              type: SnackbarType.error,
              context: context,
              content: L10n().getStr('profile.address.error'));
        }
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

  Widget mapErrorScreen() {
    return Container(
      child: Image.asset('assets/images/location_error.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              height: widget.height != null
                  ? widget.height
                  : MediaQuery.of(context).size.height * 0.5,
              child: showMapError
                  ? mapErrorScreen()
                  : showLoader ? TinyLoader() : _mapWidget()),
          SizedBox(
            height: Spacing.space20,
          ),
          Padding(
            padding:
                EdgeInsets.only(left: Spacing.space16, bottom: Spacing.space8),
            child: Text(
              L10n().getStr('profile.address.type'),
              style: Theme.of(context)
                  .textTheme
                  .body1Regular
                  .copyWith(color: ColorShades.bastille),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
            child: Wrap(
              children: <Widget>[
                ChoiceChip(
                  padding: EdgeInsets.all(Spacing.space8),
                  disabledColor: Colors.yellow,
                  avatar: Icon(Icons.home,
                      size: 16,
                      color: addressType == 'home'
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  avatarBorder: Border.all(color: Colors.red),
                  selectedColor: ColorShades.greenBg,
                  backgroundColor: ColorShades.white,
                  labelStyle: Theme.of(context).textTheme.body1Regular.copyWith(
                      color: addressType == 'home'
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  onSelected: (selected) {
                    if (selected) {
                      changeType('home');
                    }
                  },
                  label: Text(L10n().getStr('profile.address.type.home')),
                  selected: addressType == 'home',
                ),
                SizedBox(
                  width: Spacing.space4,
                ),
                ChoiceChip(
                  padding: EdgeInsets.all(Spacing.space8),
                  disabledColor: Colors.yellow,
                  avatar: Icon(Icons.work,
                      size: 16,
                      color: addressType == 'work'
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  avatarBorder: Border.all(color: Colors.red),
                  selectedColor: ColorShades.greenBg,
                  backgroundColor: ColorShades.white,
                  labelStyle: Theme.of(context).textTheme.body1Regular.copyWith(
                      color: addressType == 'work'
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  onSelected: (selected) {
                    if (selected) {
                      changeType('work');
                    }
                  },
                  label: Text(L10n().getStr('profile.address.type.work')),
                  selected: addressType == 'work',
                ),
                SizedBox(
                  width: Spacing.space4,
                ),
                ChoiceChip(
                  padding: EdgeInsets.all(Spacing.space8),
                  disabledColor: Colors.yellow,
                  avatar: Icon(Icons.location_on,
                      size: 16,
                      color: addressType == 'other'
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  avatarBorder: Border.all(color: Colors.red),
                  selectedColor: ColorShades.greenBg,
                  backgroundColor: ColorShades.white,
                  labelStyle: Theme.of(context).textTheme.body1Regular.copyWith(
                      color: addressType == 'other'
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  onSelected: (selected) {
                    if (selected) {
                      changeType('other');
                    }
                  },
                  label: Text(L10n().getStr('profile.address.type.other')),
                  selected: addressType == 'other',
                ),
                SizedBox(
                  width: Spacing.space4,
                ),
              ],
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: Spacing.space16, top: Spacing.space8),
            child: Text(
              L10n().getStr('profile.address'),
              style: Theme.of(context)
                  .textTheme
                  .body1Regular
                  .copyWith(color: ColorShades.bastille),
            ),
          ),
          Container(
            key: key,
            padding: EdgeInsets.symmetric(
                vertical: Spacing.space12, horizontal: Spacing.space16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: InputBox(
                    disabled: addressController.text.length == 0,
                    controller: addressController,
                    focusNode: _focusNode,
                    onChanged: (_) {},
                    maxLines: 3,
                    hintText: '',
                    hideShadow: true,
                  ),
                ),
                SizedBox(
                  width: Spacing.space8,
                ),
                FloatingActionButton(
                  mini: true,
                  onPressed: () async {
                    await getCurrentLocation();
                    CameraUpdate updatePosition = CameraUpdate.newLatLng(LatLng(
                        currentPosition.latitude, currentPosition.longitude));
                    mapController.animateCamera(updatePosition);
                  },
                  child: Icon(
                    Icons.my_location,
                    color: ColorShades.greenBg,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
                bottom: Spacing.space16,
                left: Spacing.space24,
                right: Spacing.space24,
                top: Spacing.space8),
            child: widget.ctaWidget != null
                ? GestureDetector(
                    onTap: () {
                      sendData();
                    },
                    child: widget.ctaWidget)
                : SecondaryButton(
                    disabled: widget.disableSend ||
                        addressController.text.length == 0,
                    shadow: Shadows.cardLight,
                    noWidth: true,
                    onPressed: () {
                      sendData();
                    },
                    text: widget.ctaText != null
                        ? widget.ctaText
                        : L10n().getStr('profile.address.addAddress'),
                  ),
          )
        ],
      ),
    );
  }
}
