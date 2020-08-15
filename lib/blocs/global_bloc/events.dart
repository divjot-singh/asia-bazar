abstract class GlobalEvents {}

class FetchSellerInfo extends GlobalEvents {
  Function callback;
  bool force;
  FetchSellerInfo({this.callback, this.force = false});
}
