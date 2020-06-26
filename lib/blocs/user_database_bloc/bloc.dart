import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/repository/user_database.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDatabaseBloc extends Bloc<UserDatabaseEvents, Map> {
  @override
  Map get initialState => UserDatabaseState.userstate;
  UserDatabase userDatabaseRepo = UserDatabase();

  @override
  Stream<Map> mapEventToState(UserDatabaseEvents event) async* {
    if (event is CheckIfAdminOrUser) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          UserDatabaseState currentState =
              await userDatabaseRepo.checkIfAdminOrUser(userId: userId);
          if (currentState == null) {
            state['userstate'] = ErrorState();
            yield {...state};
          } else {
            state['userstate'] = currentState;
            yield {...state};
          }
        } catch (e) {
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is AddUserAddress) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.addAddress(
              userId: userId, address: event.address);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);

          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is OnboardUser) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.onboardUser(
              userId: userId, address: event.address, username: event.username);

          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is UpdateUserAddress) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.updateAddress(
              userId: userId,
              address: event.address,
              timestamp: event.timestamp);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is DeleteUserAddress) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.deleteAddress(
              userId: userId, timestamp: event.timestamp);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is SetDefaultAddress) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.setDefault(
              userId: userId, timestamp: event.timestamp);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is UpdateUsername) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.updateUsername(
              userId: userId, username: event.username);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    }
  }
}
