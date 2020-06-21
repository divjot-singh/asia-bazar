import 'package:asia/shared_widgets/page_views.dart';
import 'package:flutter/material.dart';

Future<void> showCustomLoader(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext currentContext) {
      return Container(
        color: Colors.transparent.withOpacity(0.6),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: TinyLoader(),
        ),
      );
    },
  );
}
