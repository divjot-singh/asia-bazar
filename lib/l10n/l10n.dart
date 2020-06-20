class L10n {
  // static final String lang = 'en';

  static String fallbackLang = 'en';
  String lang = fallbackLang;

  static final L10n _inst = L10n._internal();

  L10n._internal();

  factory L10n() {
    return _inst;
  }

  String getLocale() {
    return lang;
  }

  // usage:
  // L10n().getStr('foobar');
  // L10n().getStr('foo', {bar: 'baz'});
  String getStr(String id, [Map<String, String> args, String forceLang]) {
    String useLang = forceLang ?? lang;
    String text = strings[useLang][id];
    if (text != null && args != null) {
      args.forEach((final String key, final value) {
        if (text.contains(key)) text = text.replaceFirst('{$key}', value ?? '');
      });
    }
    if (text == null) {
      if (useLang == fallbackLang) {
        text = id;
      } else {
        // fallback to english
        text = getStr(id, args, fallbackLang);
      }
    }
    return text;
  }
}

Map<String, Map<String, String>> strings = {
  "en": {
    "error.ERROR_INVALID_VERIFICATION_CODE": "Invalid otp",
    "error.invalidPhoneNumber": "Invalid phone number",
    "error.verifyPhoneNumberError": "Some error in authentication",
    "error.verificationFailed": "Verification Failed",
    "authentication.enterNumber":
        "Please enter your phone number. We will send you a one time password",
    "input.placeholder": "Enter your message here",
    "phoneAuthentication.resend": "Resend",
    "phoneAuthentication.verify": "Verify",
    "phoneAuthentication.verificationFailed": "Verification Failed",
    "phoneAuthentication.error.provideValue": "Please provide a value!",
    "phoneAuthentication.invalidPhoneNumber": "Please enter a valid number.",
    "phoneAuthentication.error.enterValidOTP": "Please enter a valid OTP.",
    "phoneAuthentication.error.didntGetCode": "I didn't get the code",
    "phoneAuthentication.enterCode":
        "Please enter verification code sent to {number}",
  },
  "it": {},
};
