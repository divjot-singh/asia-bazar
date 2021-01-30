import 'package:asia/l10n/l10n.dart';

class BankDetails {
  BankType bankType;
  String bankName;
  String bankAccountHoldersName;
  String accountNumber;
  String routingNumber;

  BankDetails(
      {this.bankType,
      this.bankName,
      this.bankAccountHoldersName,
      this.accountNumber,
      this.routingNumber});
}

enum BankType { checking, saving, businessChecking }

class BankUtils {
  static String validateAccountNumber(String value) {
    if (value.length < 4 || value.length > 17) {
      return L10n().getStr('payments.invalidAccountNumber');
    }
    return null;
  }

  static String validateRoutingNumber(String routing) {
    if (routing.length != 9) {
      return L10n().getStr('payments.invalidRoutingNumber');
    }
    var checksumTotal = 7 *
            (int.parse(routing[0]) +
                int.parse(routing[3]) +
                int.parse(routing[6])) +
        3 *
            (int.parse(routing[1]) +
                int.parse(routing[4]) +
                int.parse(routing[7])) +
        9 *
            (int.parse(routing[2]) +
                int.parse(routing[5]) +
                int.parse(routing[8]));

    var checksumMod = checksumTotal % 10;
    if (checksumMod != 0) {
      return L10n().getStr('payments.invalidRoutingNumber');
    }
    return null;
  }

  static String getBankType(BankType type) {
    if (type == BankType.saving) {
      return 'savings';
    } else if (type == BankType.checking) {
      return 'checking';
    } else if (type == BankType.businessChecking) {
      return 'businessChecking';
    }
  }
}
