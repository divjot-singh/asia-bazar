import 'package:asia/utils/network_manager.dart';

class PaymentRepository {
  static Future<dynamic> makeNewPayment({paymentDetails}) async {
    String url = 'apis/makeNewPayment';
    dynamic response = await NetworkManager.post(
        url: url, data: paymentDetails, sendCredentials: false);
    return response;
  }

  static Future<dynamic> makePayment({paymentDetails}) async {
    String url = 'apis/makePayment';
    dynamic response = await NetworkManager.post(
        url: url, data: paymentDetails, sendCredentials: false);
    return response;
  }

  static Future<dynamic> fetchPaymentProfiles({paymentId}) async {
    String url = 'apis/fetchPaymentProfile';
    Map<String, String> data = {};
    data['profileId'] = paymentId;
    dynamic response =
        await NetworkManager.get(url: url, data: data, sendCredentials: false);
    return response;
  }

  static Future<dynamic> makePaymentFromPaymentProfile({paymentData}) async {
    String url = 'apis/makePaymentFromPaymentProfile';
    dynamic response = await NetworkManager.post(
        url: url, data: paymentData, sendCredentials: false);
    return response;
  }

  static Future<dynamic> voidTransaction({transactionId}) async {
    String url = 'apis/voidTransaction';
    Map<String, String> paymentData = {};
    paymentData['transactionId'] = transactionId;
    dynamic response = await NetworkManager.post(
        url: url, data: paymentData, sendCredentials: false);
    return response;
  }
}
