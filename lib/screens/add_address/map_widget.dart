import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/secondary_button.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  final double height;
  final String addressType, ctaText;
  final bool disableSend;
  final Function sendCallback;
  final Widget ctaWidget;
  MapWidget(
      {this.addressType,
      this.height,
      this.ctaText,
      this.disableSend = false,
      this.ctaWidget,
      this.sendCallback});
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController mapController;
  Location location = Location();
  Geolocator locator = Geolocator();
  LocationData currentPosition =
      LocationData.fromMap({'latitude': 20, 'longitude': 77});
  Marker marker;
  String addressType;
  GlobalKey key = GlobalKey();
  bool showLoader = true;
  FocusNode _focusNode = FocusNode();
  TextEditingController addressController = TextEditingController(text: '');
  Set<Marker> markerSet;
  @override
  void initState() {
    addressType = widget.addressType != null
        ? addressType
        : L10n().getStr('profile.address.type.home');
    getCurrentLocation();
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

  getCurrentLocation() async {
    var position = await location.getLocation();

    setState(() {
      currentPosition = position;
      showLoader = false;
      markerSet = addMarker(
          LatLng(currentPosition.latitude, currentPosition.longitude));
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
              child: showLoader ? TinyLoader() : _mapWidget()),
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
                      color: addressType ==
                              L10n().getStr('profile.address.type.home')
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  avatarBorder: Border.all(color: Colors.red),
                  selectedColor: ColorShades.greenBg,
                  backgroundColor: ColorShades.white,
                  labelStyle: Theme.of(context).textTheme.body1Regular.copyWith(
                      color: addressType ==
                              L10n().getStr('profile.address.type.home')
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  onSelected: (selected) {
                    if (selected) {
                      changeType(L10n().getStr('profile.address.type.home'));
                    }
                  },
                  label: Text(L10n().getStr('profile.address.type.home')),
                  selected:
                      addressType == L10n().getStr('profile.address.type.home'),
                ),
                SizedBox(
                  width: Spacing.space4,
                ),
                ChoiceChip(
                  padding: EdgeInsets.all(Spacing.space8),
                  disabledColor: Colors.yellow,
                  avatar: Icon(Icons.work,
                      size: 16,
                      color: addressType ==
                              L10n().getStr('profile.address.type.work')
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  avatarBorder: Border.all(color: Colors.red),
                  selectedColor: ColorShades.greenBg,
                  backgroundColor: ColorShades.white,
                  labelStyle: Theme.of(context).textTheme.body1Regular.copyWith(
                      color: addressType ==
                              L10n().getStr('profile.address.type.work')
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  onSelected: (selected) {
                    if (selected) {
                      changeType(L10n().getStr('profile.address.type.work'));
                    }
                  },
                  label: Text(L10n().getStr('profile.address.type.work')),
                  selected:
                      addressType == L10n().getStr('profile.address.type.work'),
                ),
                SizedBox(
                  width: Spacing.space4,
                ),
                ChoiceChip(
                  padding: EdgeInsets.all(Spacing.space8),
                  disabledColor: Colors.yellow,
                  avatar: Icon(Icons.location_on,
                      size: 16,
                      color: addressType ==
                              L10n().getStr('profile.address.type.other')
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  avatarBorder: Border.all(color: Colors.red),
                  selectedColor: ColorShades.greenBg,
                  backgroundColor: ColorShades.white,
                  labelStyle: Theme.of(context).textTheme.body1Regular.copyWith(
                      color: addressType ==
                              L10n().getStr('profile.address.type.other')
                          ? ColorShades.white
                          : ColorShades.greenBg),
                  onSelected: (selected) {
                    if (selected) {
                      changeType(L10n().getStr('profile.address.type.other'));
                    }
                  },
                  label: Text(L10n().getStr('profile.address.type.other')),
                  selected: addressType ==
                      L10n().getStr('profile.address.type.other'),
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
                    disabled: widget.disableSend,
                    shadow: Shadows.inputLight,
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
