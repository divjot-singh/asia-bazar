import 'dart:async';
import 'dart:io';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart' show SentryClient, Event;
import 'package:device_info/device_info.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

SentryClient _sentry = new SentryClient(
  dsn:
      'https://1742ec6d566e490db0f286b16940ee40@o404283.ingest.sentry.io/5267730',
);

final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

bool get isInDebugMode {
  bool inDebugMode = false;

  assert(inDebugMode = true);

  return inDebugMode;
}

Function configureErrorTracking = () {
  configureCrashlytics();
};

void configureCrashlytics() async {
  var userId = await StorageManager.getItem(KeyNames['userId']);
  Crashlytics.instance.log('Setting user identifier $userId in crashlytics');
  Crashlytics.instance.setUserIdentifier(userId);
}

Future<Event> getSentryEnvEvent(dynamic exception, dynamic stackTrace) async {
  var userId = await StorageManager.getItem(KeyNames['userId']);
  if (Platform.isIOS) {
    final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    return Event(
      // release: '', todo: Pick this from pubspec
      extra: <String, dynamic>{
        'name': iosDeviceInfo.name,
        'model': iosDeviceInfo.model,
        'systemName': iosDeviceInfo.systemName,
        'systemVersion': iosDeviceInfo.systemVersion,
        'localizedModel': iosDeviceInfo.localizedModel,
        'utsname': iosDeviceInfo.utsname.sysname,
        'identifierForVendor': iosDeviceInfo.identifierForVendor,
        'isPhysicalDevice': iosDeviceInfo.isPhysicalDevice,
        'userId': userId
      },
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    return Event(
      // release: '', todo: Pick this from pubspec
      extra: <String, dynamic>{
        'type': androidDeviceInfo.type,
        'model': androidDeviceInfo.model,
        'device': androidDeviceInfo.device,
        'id': androidDeviceInfo.id,
        'androidId': androidDeviceInfo.androidId,
        'brand': androidDeviceInfo.brand,
        'display': androidDeviceInfo.display,
        'hardware': androidDeviceInfo.hardware,
        'manufacturer': androidDeviceInfo.manufacturer,
        'product': androidDeviceInfo.product,
        'version': androidDeviceInfo.version.release,
        'supported32BitAbis': androidDeviceInfo.supported32BitAbis,
        'supported64BitAbis': androidDeviceInfo.supported64BitAbis,
        'supportedAbis': androidDeviceInfo.supportedAbis,
        'isPhysicalDevice': androidDeviceInfo.isPhysicalDevice,
        'userId': userId
      },
      exception: exception,
      stackTrace: stackTrace,
    );
  }
}

Future<void> recordDartError(dynamic error, dynamic stackTrace) async {
  print('Caught error: $error');

  if (isInDebugMode) {
    print('Not Sending report to sentry.io as this is debug mode');
    print(stackTrace);
    return;
  } else {
    try {
      final Event event = await getSentryEnvEvent(error, stackTrace);
      print('Sending report to sentry.io $event');
      await _sentry.capture(event: event);
    } catch (e) {
      print('Sending report to sentry.io failed: $e');
      print('Original error: $error');
    }
    Crashlytics.instance.recordError(error, stackTrace);
  }
}

Function recordFlutterError = (FlutterErrorDetails details) {
  if (isInDebugMode) {
    FlutterError.dumpErrorToConsole(details);
  } else {
    Zone.current.handleUncaughtError(details.exception, details.stack);
    Crashlytics.instance.recordFlutterError(details);
  }
};
