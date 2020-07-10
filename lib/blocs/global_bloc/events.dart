abstract class GlobalEvents {}

class FetchSellerInfo extends GlobalEvents {
  Function callback;
  FetchSellerInfo({this.callback});
}
