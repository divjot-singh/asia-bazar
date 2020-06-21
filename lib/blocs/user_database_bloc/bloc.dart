import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/repository/user_database.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDatabaseBloc extends Bloc<UserDatabaseEvents, UserDatabaseState> {
  @override
  // TODO: implement initialState
  UserDatabaseState get initialState => UnInitialisedState();
  UserDatabase userDatabaseRepo = UserDatabase();

  @override
  Stream<UserDatabaseState> mapEventToState(UserDatabaseEvents event) async* {
    if (event is CheckIfAdminOrUser) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        yield ErrorState();
      } else {
        try {
          UserDatabaseState state =
              await userDatabaseRepo.checkIfAdminOrUser(userId: userId);
          if (state == null) {
            yield ErrorState();
          } else {
            yield state;
          }
        } catch (e) {
          yield ErrorState();
        }
      }
    } else if (event is AddUserAddress) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        yield ErrorState();
      } else {
        try {
          await userDatabaseRepo.addAddress(
              userId: userId, address: event.address);
          if (state == null) {
            if (event.callback != null) {
              event.callback(false);
            }
            yield ErrorState();
          } else {
            if (event.callback != null) {
              event.callback(true);
            }
            yield state;
          }
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          yield ErrorState();
        }
      }
    }
  }
}
