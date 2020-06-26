import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/app_drawer.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        drawer: AppDrawer(),
        appBar: MyAppBar(
            hasTransparentBackground: true,
            title: L10n().getStr('home.title'),
            hideBackArrow: true,
            leading: {
              'icon': Icon(Icons.dehaze),
              'onTap': (ctx) => {Scaffold.of(ctx).openDrawer()}
            }),
        body: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "You are Logged in succesfully",
                style: TextStyle(color: Colors.lightBlue, fontSize: 32),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "ddasdasda",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
