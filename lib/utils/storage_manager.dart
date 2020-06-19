import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static Future<dynamic> getItem(String key) async {
    SharedPreferences prefInstance = await SharedPreferences.getInstance();
    dynamic value = await prefInstance.get(key);
    return value;
  }

  static Future<bool> setItem(String key, dynamic value) async {
    if (value is List || value is Map) {
      value = jsonEncode(value);
    } else if (value is! bool && value is! int && value is! double) {
      value = value.toString();
    }

    SharedPreferences prefInstance = await SharedPreferences.getInstance();
    bool result;
    if (value is String)
      result = await prefInstance.setString(key, value);
    else if (value is double)
      result = await prefInstance.setDouble(key, value);
    else if (value is int)
      result = await prefInstance.setInt(key, value);
    else if (value is bool)
      result = await prefInstance.setBool(key, value);
    else
      result = await prefInstance.setString(key, value);
    return result;
  }

  static Future<bool> deleteItem(String key) async {
    SharedPreferences prefInstance = await SharedPreferences.getInstance();
    bool result = await prefInstance.remove(key);
    return result;
  }
}
