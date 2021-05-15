import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/order_bloc/event.dart';
import 'package:asia/blocs/order_bloc/state.dart';
import 'package:asia/repository/order_database.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderDetailsBloc extends Bloc<OrderEvent, Map> {
  OrderDetailsBloc(Map initialState) : super(initialState);

  @override
  Map get initialState => OrderState.orderState;

  OrderDatabaseRepo orderRepo = OrderDatabaseRepo();

  @override
  Stream<Map> mapEventToState(OrderEvent event) async* {
    if (event is FetchOrderDetails) {
      state['orderState'] = GlobalFetchingState();
      yield {...state};
      var userId = await StorageManager.getItem(KeyNames['userId']);
      try {
        var order = await orderRepo.fetchOrderDetails(
            orderId: event.orderId, userId: userId);
        if (order == null) {
          state['orderState'] = GlobalErrorState();
        } else {
          state['orderState'] = OrderFetchedState(orderDetails: order);
        }
      } catch (e) {
        state['orderState'] = GlobalErrorState();
      }
      yield {...state};
    } else if (event is FetchOrderItems) {
      state['itemState'] = GlobalFetchingState();
      yield {...state};
      try {
        var items = await orderRepo.fetchOrderItems(orderId: event.orderId);
        if (items == null) {
          state['itemState'] = GlobalErrorState();
        } else {
          state['itemState'] =
              ItemFetchedState(orderId: event.orderId, orderItems: items);
        }
        if (event.callback != null) {
          event.callback(items);
        }
      } catch (e) {
        state['itemState'] = GlobalErrorState();
      }
      yield {...state};
    }
  }
}
