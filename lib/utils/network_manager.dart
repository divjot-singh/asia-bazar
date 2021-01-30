import 'dart:convert' as convert;
import 'package:asia/l10n/l10n.dart';
import 'package:asia/services/log_printer.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http/http.dart' as http;

import 'package:logger/logger.dart';

class NetworkManager {
  static String className = 'NetworkManager';
  static final logger = getLogger(className);

  static var apiUrl = URLS['api_url'];
  static Future _makeRequest(
    String url,
    String type,
    Map data,
    bool sendCredentials,
    bool noSnackbar,
    bool isAbsoluteUrl,
  ) async {
    HttpClientWithInterceptor client = HttpClientWithInterceptor.build(
      interceptors: [RequestInterceptor()],
    );
    //Uri uri=Uri.parse(url);
    //http.Request request = http.Request(type,uri);

    http.Response response;
    if (!isAbsoluteUrl) {
      url = apiUrl + '/' + url;
    }
    try {
      logger.i(url);
      if (sendCredentials) data = await NetworkManager._getBaseData(data);
      Logger().d(
        data,
      );
      Map<String, String> headers = {
        "content-type": "application/x-www-form-urlencoded",
      };
      if (type == 'POST') {
        response = await client.post(url, body: data, headers: headers);
      } else if (type == 'GET') {
        response = await client.get(url, params: data, headers: headers);
      }
      Map<dynamic, dynamic> responseBody;

      if (response.statusCode >= 200 && response.statusCode < 400) {
        responseBody = convert.jsonDecode(response.body);
        return responseBody;
        if (responseBody["success"]) {
          Logger().d(responseBody['data']);
          return responseBody['data'];
        } else {
          return NetworkManager._handleError(
            errorMsg: responseBody['data']['error'] ?? '',
            errorCode: responseBody['code'],
            url: url,
            noSnackbar: noSnackbar,
          );
        }
      } else {
        throw Exception('Error in fetching api response ' + response.body);
      }
    } catch (error) {
      return NetworkManager._handleError(
        errorMsg: error.toString(),
        errorCode: response != null ? response.statusCode : 1,
        url: url,
        noSnackbar: noSnackbar,
      );
    } finally {}
    // String res= await response.stream.bytesToString();
    // dynamic responseout = convert.jsonDecode(res);
    // logger.i(responseout);
  }

  static Map _handleError({
    String errorMsg,
    int errorCode = 1,
    Exception exception,
    String url,
    bool noSnackbar,
  }) {
    String errorString, errorStringId;
    // if (errorCode != null && RESPONSE_CODES[errorCode] != null) {
    //   errorStringId = 'error.' + RESPONSE_CODES[errorCode];
    //   // errorString = RESPONSE_CODES[errorCode];
    //   errorString = L10n().getStr(errorStringId);
    //   //errorString = <FormattedMessage id={errorStringId} />
    // }
    if (errorString == null || errorString == '') {
      if (errorMsg.length > 0)
        errorString = errorMsg;
      else
        errorString = errorCode.toString();
    }
    return {
      "message": errorString,
      "id": errorStringId,
      "errorCode": errorCode
    };
  }

  static get({
    @required String url,
    Map data,
    bool sendCredentials = true,
    bool noSnackbar = false,
    bool isAbsoluteUrl = false,
  }) {
    return _makeRequest(
        url, 'GET', data, sendCredentials, noSnackbar, isAbsoluteUrl);
  }

  static post(
      {@required String url,
      Map data,
      bool noSnackbar = false,
      bool sendCredentials = true,
      bool isAbsoluteUrl = false}) {
    return _makeRequest(
        url, 'POST', data, sendCredentials, noSnackbar, isAbsoluteUrl);
  }

  static Future<Map<String, String>> _getBaseData(Map data) async {
    data = data is Map ? data : {};

    String userId = await StorageManager.getItem(KeyNames["userId"]);
    String token = await StorageManager.getItem(KeyNames["token"]);
    String lang = L10n().getLocale();
    // String simCountryCode = await FlutterSimCountryCode.simCountryCode;
    // todo set it once

    if (userId != null) data["user_id"] = userId;
    if (token != null) data["token"] = token;
    if (lang != null) data["lang"] = lang;
    // if (simCountryCode != null) data["country"] = simCountryCode;

    data = data.map((key, value) => MapEntry(key, value.toString()));
    return Map.from(data);
  }
}

class RequestInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {
    return data;
  }
}
