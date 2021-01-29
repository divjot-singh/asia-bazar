import 'dart:async';

import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  PaymentScreen({@required this.amount});
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  ThemeData theme;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('paymentScreen.header'),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return WebView(
              initialUrl:
                  'http://192.168.1.6:3030/payments?amount=${widget.amount}',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController wvCtrl) {
                _controller.complete(wvCtrl);
              },
              gestureRecognizers: Set()
                ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()
                  ..onTapDown = (tap) {
                    SystemChannels.textInput.invokeMethod(
                        'TextInput.hide'); //This will hide keyboard ontapdown
                  })),
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  print('blocking navigation to $request}');
                  return NavigationDecision.prevent;
                }
                print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {
                print('Page started loading: $url');
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
              },
              gestureNavigationEnabled: true,
            );
          },
        ),
      ),
    );
  }
}
