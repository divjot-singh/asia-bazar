import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Redirector extends StatefulWidget {
  @override
  _RedirectorState createState() => _RedirectorState();
}

class _RedirectorState extends State<Redirector> {
  @override
  void initState() {
    BlocProvider.of<UserDatabaseBloc>(context).add(CheckIfAdminOrUser());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserDatabaseBloc, UserDatabaseState>(
      listener: (context, state) {
        if (state is UserIsAdmin) {
          Navigator.pushReplacementNamed(context, Constants.ADMIN_PROFILE);
        } else if (state is UserIsUser) {
          //Navigator.pushReplacementNamed(context, Constants.ADMIN_PROFILE);

          Navigator.pushReplacementNamed(context, Constants.HOME);
        } else if (state is NewUser) {
          Navigator.pushReplacementNamed(context, Constants.ADD_ADDRESS,
              arguments: {'first': true});
        }
      },
      child: BlocBuilder<UserDatabaseBloc, UserDatabaseState>(
        builder: (context, state) {
          if (state is ErrorState) {
            return PageErrorView();
          }
          return Container(
            decoration: BoxDecoration(gradient: Gradients.lightPink),
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: PageFetchingView(),
            ),
          );
        },
      ),
    );
  }
}
