// import 'package:asia/blocs/user_database_bloc/bloc.dart';
// import 'package:asia/blocs/user_database_bloc/state.dart';
// import 'package:asia/l10n/l10n.dart';
// import 'package:asia/shared_widgets/app_bar.dart';
// import 'package:asia/shared_widgets/input_box.dart';
// import 'package:asia/shared_widgets/page_views.dart';
// import 'package:asia/theme/style.dart';
// import 'package:asia/utils/constants.dart';
// import 'package:asia/utils/utilities.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:location/location.dart';

// class EditProfile extends StatefulWidget {
//   @override
//   _EditProfileState createState() => _EditProfileState();
// }

// class _EditProfileState extends State<EditProfile> {
//   Map user;
//   Map userData;
//   TextEditingController addressController = TextEditingController();
//   bool expandTextField = false;
//   final dataKey = new GlobalKey();
//   FocusNode _focusNode = FocusNode();
//   @override
//   void initState() {
//     var state = BlocProvider.of<UserDatabaseBloc>(context).state;
//     if (state is NewUser) {
//       user = state.user;
//     } else if (state is UserIsUser) {
//       user = state.user;
//     } else {
//       user = null;
//     }
//     userData = {...user};
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus) {
//         scrollAddressBarToBottom();
//       }
//     });
//     super.initState();
//   }

//   scrollAddressBarToBottom() {
//     Scrollable.ensureVisible(
//       dataKey.currentContext,
//       alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
//     );
//   }

//   fetchLocation() async {
//     Location location = new Location();

//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;
//     LocationData _locationData;

//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     _locationData = await location.getLocation();
//     print(_locationData);
//     final coordinates =
//         new Coordinates(_locationData.latitude, _locationData.longitude);
//     var addresses =
//         await Geocoder.local.findAddressesFromCoordinates(coordinates);
//     print(addresses);
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     bool _keyboardIsVisible = Utilities.keyboardIsVisible(context);
//     var firstHalfTextColor =
//         _keyboardIsVisible ? ColorShades.darkPink : ColorShades.white;
//     var secondHalfTextColor =
//         _keyboardIsVisible ? ColorShades.white : ColorShades.darkPink;

//     return SafeArea(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: _keyboardIsVisible
//               ? Gradients.greenGradient
//               : Gradients.greenGradientReverse,
//         ),
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: MyAppBar(
//             hasTransparentBackground: true,
//             textColor: firstHalfTextColor,
//             hideBackArrow: true,
//             title: L10n().getStr('profile.updateProfile'),
//           ),
//           body: user == null
//               ? PageErrorView()
//               : SingleChildScrollView(
//                   child: Container(
//                     padding: EdgeInsets.all(Spacing.space16),
//                     width: MediaQuery.of(context).size.width,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         SizedBox(
//                           height: Spacing.space32,
//                         ),
//                         Text(
//                           L10n().getStr('profile.updateProfile.welcome',
//                               {'username': userData[KeyNames['userName']]}),
//                           style: theme.textTheme.h1
//                               .copyWith(color: firstHalfTextColor),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(
//                           height: Spacing.space16,
//                         ),
//                         Text(
//                           L10n().getStr(
//                             'profile.updateprofile.info',
//                           ),
//                           style: theme.textTheme.h3
//                               .copyWith(color: firstHalfTextColor),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(
//                           height: Spacing.space20,
//                         ),
//                         Container(
//                           width: MediaQuery.of(context).size.width,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 L10n().getStr(
//                                   'profile.updateProfile.username',
//                                 ),
//                                 style: theme.textTheme.h4
//                                     .copyWith(color: firstHalfTextColor),
//                               ),
//                               SizedBox(
//                                 height: Spacing.space12,
//                               ),
//                               InputBox(
//                                 value: userData[KeyNames['username']],
//                                 onChanged: (value) {
//                                   userData[KeyNames['username']] = value;
//                                 },
//                                 hintText: 'I am Ironman',
//                               ),
//                               SizedBox(
//                                 height: Spacing.space16,
//                               ),
//                               Text(
//                                 L10n().getStr(
//                                   'profile.updateProfile.address',
//                                 ),
//                                 style: theme.textTheme.h4.copyWith(
//                                     color: theme.colorScheme.textPrimaryLight),
//                               ),
//                               SizedBox(
//                                 height: Spacing.space16,
//                               ),
//                               Row(
//                                 key: dataKey,
//                                 children: <Widget>[
//                                   Expanded(
//                                     child: Padding(
//                                       padding: EdgeInsets.only(
//                                           bottom: Spacing.space4),
//                                       child: InputBox(
//                                         controller: addressController,
//                                         onChanged: (value) {
//                                           if (addressController.text.length >
//                                               0) {
//                                             setState(() {
//                                               expandTextField = true;
//                                             });
//                                             scrollAddressBarToBottom();
//                                           } else {
//                                             setState(() {
//                                               expandTextField = false;
//                                             });
//                                           }
//                                         },
//                                         hintText: '',
//                                         maxLines: expandTextField ? 4 : 1,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: Spacing.space12,
//                                   ),
//                                   IconButton(
//                                     icon: Icon(Icons.my_location),
//                                     onPressed: () {
//                                       fetchLocation();
//                                     },
//                                     color: secondHalfTextColor,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }
