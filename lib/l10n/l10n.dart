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
    "error.invalidCredential": "Invalid phone number",
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
    "redirector.userIsAdmin":
        "You are already registered as an admin on Asia Bazar",
    "redirector.userIsAdmin.info":
        "You can not register as an admin and a user from the same number. Please go back and login using a different phone number",
    "redirector.goBack": "Go Back",
    "profile.updateProfile": "Update Profile",
    "profile.updateProfile.welcome": "Welcome aboard {username}!",
    "profile.updateprofile.info":
        "Please add a username and address to continue",
    "profile.updateProfile.username": "What should we call you?",
    "profile.updateProfile.address":
        "Please add a default address. You can always change that later.",
    "profile.address.add": "Add location",
    "profile.address.added": "Address succesfully saved",
    "profile.address.error": "Something went wrong",
    "profile.address.addAddress": "Add address",
    "home.title": "Home",
    "drawer.hi": "Hi, {name}",
    "drawer.editUsername": "You need to add a username",
    "drawer.addAddress": 'Add address',
    "drawer.logout": "Log out",
    "drawer.orders": "My orders",
    "drawer.addressList": "Address book",
    "profile.address.type": "Address type",
    "profile.address.type.home": "Home",
    "profile.address.type.work": "Work",
    "profile.address.type.other": "Other",
    "profile.address": "Address",
    "onboarding.title": "Welcome",
    "onboarding.name": "What should we call you?",
    "onboarding.message": "Please add a default location",
    "onboarding.name.error": "Please enter a value",
    "onboarding.name.hint": "I am Ironman",
    "onboarding.cta.title": "Next",
    "address.default": "Default",
    "home.drawer.noOrder": "Place your first order with us",
    "address.updateLocation": "Update location",
    "address.setDefault": "Set as default address",
    "address.edit": "Edit address",
    "address.delete": "Delete address",
    "address.delete.confirmation":
        "Are you sure you want to delete this address?",
    "confirmation.cancel": "Cancel",
    "confirmation.delete": "Delete",
    "editProfile.username": "Name",
    "editProfile.phone": "Phone number",
    "editProfile.profile": "Profile",
    "editProfile.defaultAddress": "Default address",
    "editProfile.more": "more",
    "myOrders.heading": "My orders",
    "myOrders.noOrders": "You have not placed an order yet!",
    "drawer.cart": "Cart",
    "cart.empty": "There are no items in your cart. Go back and add some!",
    "list.empty":"No items found",
    "home.search":"Search items",
    "home.shopByCategory":"Shop by category",
    "category.search":"Search {category}",
    "item.add":"Add",
  },
  "it": {},
};
