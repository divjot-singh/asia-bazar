import 'package:asia/blocs/global_bloc/events.dart';
import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/repository/global_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalBloc extends Bloc<GlobalEvents, Map> {
  @override
  Map get initialState => GlobalState.globalState;
  GlobalRepo _globalRepo = GlobalRepo();
  @override
  Stream<Map> mapEventToState(GlobalEvents event) async* {
    if (event is FetchSellerInfo) {
      if (state['sellerInfo'] != InfoFetchedState) {
        var info = await _globalRepo.fetchSellerInfo();
        if (event.callback != null) {
          event.callback(info);
        }
        state['sellerInfo'] = InfoFetchedState(sellerInfo: info);
        yield {...state};
      } else {
        event.callback(state['sellerInfo'].sellerInfo);
      }
    }
  }
}
