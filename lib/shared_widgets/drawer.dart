// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gametvflutter/repositories/clubs_chat.dart';
// import 'package:gametvflutter/repositories/tournament_chat.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:gametvflutter/admin_webview.dart';
// import 'package:gametvflutter/l10n/l10n.dart';
// import 'package:gametvflutter/shared_widgets/primary_button.dart';
// import 'package:gametvflutter/theme/style.dart';
// import 'package:gametvflutter/blocs/oauth/bloc.dart';
// import 'package:gametvflutter/blocs/oauth/events.dart';
// import 'package:gametvflutter/util/constants.dart';
// import 'package:gametvflutter/util/storage_manager.dart';
// import 'package:gametvflutter/services/log_printer.dart';

// class MyDrawer extends StatelessWidget {
//   static String className = 'MyDrawer';
//   static final logger = getLogger(className);

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         width: 282.0,
//         child: Drawer(
//           child: Column(
//             children: [
//               Header(parentContext: context),
//               Divider(
//                 height: 1.0,
//               ),
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: Spacing.space16,
//                   ),
//                   decoration: BoxDecoration(
//                     color: ColorShades.white,
//                   ),
//                   child: ListView(
//                     children: <Widget>[
//                       listItem(context, 'assets/images/play_color.png',
//                           'bottomNav.icon.play', () {
//                         Navigator.popAndPushNamed(
//                           context,
//                           Constants.HOME,
//                         );
//                       }),
//                       listItem(context, 'assets/images/leaderboard_color.png',
//                           'leaderboard.heading', () {
//                         Navigator.popAndPushNamed(
//                           context,
//                           Constants.LEADERBOARD,
//                         );
//                       }),
//                       listItem(context, 'assets/images/favourite_color.png',
//                           'drawer.fav', () {
//                         Navigator.popAndPushNamed(
//                           context,
//                           Constants.SETGAMES,
//                         );
//                       }),
//                       listItem(context, 'assets/images/notification_color.png',
//                           'notifications.heading', () {
//                         Navigator.popAndPushNamed(
//                           context,
//                           Constants.NOTIFICATIONS,
//                         );
//                       }),
//                       listItem(context, 'assets/images/guild.png',
//                           'clubs.guildsAndCommunities', () {
//                         Navigator.popAndPushNamed(
//                             context, Constants.CLUBS_SEARCH);
//                       }),
//                       Divider(),
//                       listItem(
//                         context,
//                         'assets/images/privacy_color.png',
//                         'drawer.privacyPolicy',
//                         () async {
//                           String url = 'https://www.game.tv/privacy-and-policy';
//                           if (await canLaunch(url)) {
//                             await launch(url);
//                           } else {
//                             throw 'Could not launch $url';
//                           }
//                         },
//                       ),
//                       listItem(
//                         context,
//                         'assets/images/logout_color.png',
//                         'home.labels.logOut',
//                         () {
//                           AuthBloc _authbloc = AuthBloc();
//                           _authbloc.add(
//                             Logout(
//                               callback: () {
//                                 Navigator.pushNamedAndRemoveUntil(
//                                   context,
//                                   Constants.OAUTH,
//                                   (Route<dynamic> route) => false,
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Divider(
//                 height: 1.0,
//               ),
//               Footer(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   InkWell listItem(
//       BuildContext context, String imagePath, String textId, Function onTap) {
//     List<Widget> children = <Widget>[];
//     if (imagePath != null) {
//       children.add(
//         Padding(
//           padding: const EdgeInsets.only(right: Spacing.space12),
//           child: Image(image: AssetImage(imagePath), height: 24.0, width: 24.0),
//         ),
//       );
//     }
//     children.add(
//       Expanded(
//         child: Text(
//           L10n().getStr(textId) ?? '',
//           softWrap: true,
//           style: Theme.of(context).textTheme.h4.copyWith(
//               color: Theme.of(context).colorScheme.textPrimaryDark,
//               fontFamily: 'Rounded Mplus 1c',
//               fontSize: 16.0,
//               fontWeight: FontWeight.w400),
//         ),
//       ),
//     );

//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         height: 42.0,
//         margin: EdgeInsets.symmetric(
//           vertical: Spacing.space4,
//         ),
//         child: Row(
//           children: children,
//         ),
//       ),
//     );
//   }
// }

// class Header extends StatelessWidget {
//   Header({Key key, this.parentContext}) : super(key: key);
//   final BuildContext parentContext; // todo remove unused parent context
//   String avatarUrl, phoneNumber, userName, eloRating;
//   Future _getItemsFromLocalStorage() async {
//     phoneNumber =
//         await StorageManager.getItem(PersistentStorageKeys["phoneNumber"]);
//     avatarUrl =
//         await StorageManager.getItem(PersistentStorageKeys["avatarUrl"]);
//     userName = await StorageManager.getItem(PersistentStorageKeys["userName"]);
//     var rating =
//         await StorageManager.getItem(PersistentStorageKeys["highestRating"]);
//     eloRating = rating.toString();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _getItemsFromLocalStorage(),
//       builder: (context, snapshot) {
//         return InkWell(
//           onTap: () => Navigator.popAndPushNamed(
//             context,
//             Constants.USER.replaceAll(':profileId', ''),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: ColorShades.white,
//             ),
//             padding: EdgeInsets.fromLTRB(
//               Spacing.space16,
//               Spacing.space24,
//               Spacing.space16,
//               Spacing.space28,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Avatar(avatarUrl: avatarUrl),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         userName ?? phoneNumber ?? '',
//                         style: Theme.of(context).textTheme.h3.copyWith(
//                               color:
//                                   Theme.of(context).colorScheme.textPrimaryDark,
//                               fontFamily: 'Rounded Mplus 1c',
//                               fontSize: 20.0,
//                               fontWeight: FontWeight.w800,
//                             ),
//                       ),
//                       SizedBox(height: Spacing.space4),
//                       (eloRating != null && eloRating != '' && eloRating != '0')
//                           ? Text(
//                               L10n().getStr(
//                                   "drawer.user.elo", {'rating': eloRating}),
//                               style: Theme.of(context).textTheme.h4.copyWith(
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .textSecOrange,
//                                     fontFamily: 'Rounded Mplus 1c',
//                                     fontSize: 14.0,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                             )
//                           : Container(),
//                     ],
//                   ),
//                 ),
//                 Image(
//                   image: AssetImage('assets/images/arrow_right_blue.png'),
//                   height: 12.0,
//                   width: 24.0,
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class Avatar extends StatelessWidget {
//   const Avatar({Key key, @required this.avatarUrl}) : super(key: key);

//   final String avatarUrl;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(right: Spacing.space16),
//       height: 56.0,
//       width: 56.0,
//       padding: EdgeInsets.all(Spacing.space4),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Theme.of(context).colorScheme.shadowLight,
//               offset: Offset(0, 4),
//               blurRadius: 12,
//             ),
//           ]),
//       child: CircleAvatar(
//         backgroundImage: NetworkImage(avatarUrl ?? ''),
//       ),
//     );
//   }
// }

// class Footer extends StatelessWidget {
//   const Footer({
//     Key key,
//   }) : super(key: key);

//   Widget drawer(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(Spacing.space16),
//       decoration: BoxDecoration(
//         color: ColorShades.smokeWhite,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(bottom: Spacing.space8),
//             child: Text(
//               L10n().getStr('drawer.hostTourn.title'),
//               style: Theme.of(context).textTheme.h3.copyWith(
//                     color: Theme.of(context).colorScheme.textPrimaryDark,
//                     fontFamily: 'Rounded Mplus 1c',
//                     fontWeight: FontWeight.w500,
//                     fontSize: 18.0,
//                   ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: Spacing.space8),
//             child: Text(
//               L10n().getStr('drawer.hostTourn.more'),
//               style: Theme.of(context).textTheme.body1Regular.copyWith(
//                     color: Theme.of(context).colorScheme.textSecGray3,
//                     fontFamily: 'Rounded Mplus 1c',
//                     fontSize: 16.0,
//                   ),
//             ),
//           ),
//           PrimaryButton(
//               width: double.infinity,
//               text: L10n().getStr('drawer.hostTourn.btn'),
//               onPressed: () async {
//                 Navigator.pop(context);

//                 String route = Constants.WEBVIEW;
//                 String url = await AdminWebview.url('all_tournaments');

//                 Navigator.of(context).pushNamed(route, arguments: {'url': url});
//                 // Navigator.pushNamed(context, route, arguments: { 'url': 'https://qa2-nrp.game.tv/dashboard/oauth_redirect?token=fa741716-690f-4a33-b6ea-81df2b486662&user_id=Y81Cu3lNJGfGHVJBnrKRU30YHr72&extra_fields=%7B%7D&path=dashboard%2Fall_tournaments&email=null'
//               }),
//           // onPressed: () => BlocProvider.of<ProfileBloc>(context) .add(FetchProfileEvent())),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return drawer(context);
//   }
// }
