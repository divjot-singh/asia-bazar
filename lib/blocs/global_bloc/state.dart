abstract class GlobalState {}

class GlobalErrorState extends GlobalState {
  final String text;
  GlobalErrorState({this.text});
}

class GlobalFetchingState extends GlobalState {}
