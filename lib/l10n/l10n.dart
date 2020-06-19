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
    "error.invalidCredential": "Invalid phone number",
    "error.verificationFailed": "Verification Failed",
  },
  "it": {},
};
