import 'package:asia/route_generator.dart';
import 'package:asia/screens/authentication_screen/authentication_screen.dart';
import 'package:asia/services/log_printer.dart';
import 'package:asia/theme/style.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/l10n.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends StatelessWidget {
  static String className = 'App';
  static final logger = getLogger(className);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: FutureBuilder(
          // future: Devicelocale.currentLocale,
          future: Devicelocale.preferredLanguages,
          builder: (context, snapshot) {
            // initialize L10n singleton
            L10n l10n = L10n();
            if (snapshot.hasData) {
              String locale = snapshot.data[0];
              String lang = locale.substring(0, 2);
              logger.i('lang$lang');
              if (lang is String) {
                l10n.lang = lang;
              }
            }

            return MaterialApp(
              title: 'game.tv',
              theme: appTheme(),
              navigatorObservers: [routeObserver],
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                // GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('en'),
                const Locale('de'),
                const Locale('es'),
                const Locale('fr'),
                const Locale('it'),
                const Locale('ja'),
                const Locale('ko'),
                const Locale('pl'),
                const Locale('pt'),
                const Locale('ru'),
                const Locale('th'),
                const Locale('tr'),
                const Locale('vi'),
                const Locale('zh'),
              ],
              // Initially display home page
              home: AuthenticationScreen(),
              initialRoute: '/',
              onGenerateRoute: RouteGenerator.generateRoute,
              // routes: {
              //   Constants.WEBVIEW: (context) => ExtractArgumentsScreen(),
              // }
            );
          }),
    );
  }
}
// A widget that extracts the necessary arguments from the ModalRoute.

// class ExtractArgumentsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     Map args = ModalRoute.of(context).settings.arguments;
//     return SafeArea(
//       child: new WebviewScaffold(
//         url: args['url'],
//       ),
//     );
//   }
// }
