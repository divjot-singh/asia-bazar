import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';

class HomeAppBar extends StatefulWidget {
  final TabController tabController;
  final bool isScrolled;
  HomeAppBar({@required this.tabController, this.isScrolled = false});

  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false, _islistening = false;

  String transcription = '';

  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    checkForPermissions();
    super.initState();
  }

  checkForPermissions() async {
    var status = await Permission.microphone.isGranted;
    if (status) {
      activateSpeechRecognizer();
    } else {
      var isPermanentlyDenied = await Permission.microphone.isPermanentlyDenied;
      if (!isPermanentlyDenied) {
        PermissionStatus newStatus = await Permission.microphone.request();
        if (newStatus == PermissionStatus.granted) {
          activateSpeechRecognizer();
        }
      }
    }
  }

  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.activate().then((res) {
      print(res);
      setState(() => _speechRecognitionAvailable = res);
    });
  }

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (_focusNode.hasFocus) _focusNode.unfocus();
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.disabled,
      pinned: true,
      expandedHeight: MediaQuery.of(context).size.height * 0.45,
      centerTitle: true,
      forceElevated: widget.isScrolled,
      title: Text(
        L10n().getStr('app.title'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.pageTitle,
      ),
      actions: <Widget>[
        BlocBuilder<UserDatabaseBloc, Map>(
          builder: (context, state) {
            var currentState = state['userstate'];
            if (currentState is UserIsUser) {
              return Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Constants.CART);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: Spacing.space8),
                    padding: EdgeInsets.symmetric(
                        horizontal: Spacing.space16, vertical: Spacing.space8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: ColorShades.greenBg,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.shopping_cart,
                          size: 20,
                        ),
                        SizedBox(
                          width: Spacing.space4,
                        ),
                        Text(
                          currentState.user['cart'].length.toString(),
                          style: theme.textTheme.h4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ],
      // to keep a minimum height of app bar + game banner
      bottom: PreferredSize(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.space16,
                ),
                child: InputBox(
                  onChanged: (_) {},
                  onTap: () {
                    print(_islistening);
                    Navigator.pushNamed(
                            context,
                            Constants.SEARCH.replaceAll(
                                ":listening", _islistening.toString()))
                        .then((_) {
                      setState(() {
                        _islistening = false;
                      });
                    });
                  },
                  focusNode: _focusNode,
                  hideShadow: true,
                  suffixIcon: _speechRecognitionAvailable
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              _islistening = true;
                            });
                          },
                          child: Icon(
                            Icons.mic,
                            color: ColorShades.green,
                            size: 24,
                          ),
                        )
                      : null,
                  hintText: L10n().getStr('home.search'),
                  prefixIcon: Icon(
                    Icons.search,
                    color: ColorShades.greenBg,
                  ),
                ),
              ),
              SizedBox(
                height: Spacing.space24,
              ),
              Container(
                color: ColorShades.white,
                child: TabBar(
                  controller: widget.tabController,
                  indicatorColor: ColorShades.darkGreenBg,
                  labelStyle: theme.textTheme.body1Bold,
                  unselectedLabelStyle: theme.textTheme.body1Regular,
                  labelColor: ColorShades.greenBg,
                  unselectedLabelColor: ColorShades.grey300,
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(
                        Icons.home,
                      ),
                      text: L10n().getStr('home.title'),
                    ),
                    Tab(
                      icon: Icon(Icons.view_module),
                      text: L10n().getStr('app.categories'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        preferredSize: Size.fromHeight(150.0),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            color: theme.colorScheme.disabled,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/images/home_image.jpg'),
            )),
        child: Container(
          color: ColorShades.bastille.withOpacity(0.4),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}
