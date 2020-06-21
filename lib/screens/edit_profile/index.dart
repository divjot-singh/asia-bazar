import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Map user;
  @override
  void initState() {
    var state = BlocProvider.of<UserDatabaseBloc>(context).state;
    if (state is NewUser) {
      user = state.user;
    } else if (state is UserIsUser) {
      user = state.user;
    } else {
      user = null;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        hideBackArrow: true,
        title: L10n().getStr('profile.updateProfile'),
      ),
      body: user == null ? PageErrorView() : Container(
        decoration: BoxDecoration(
          
        ),
      ),
    );
  }
}
