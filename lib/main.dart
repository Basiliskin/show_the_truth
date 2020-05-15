import 'package:flutter/material.dart';
import 'package:knesset_odata/screen/time.screen.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:knesset_odata/model/navigation.model.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/viewmodel/start.viewmodel.dart';
import 'package:knesset_odata/screen/home.screen.dart';
import 'package:knesset_odata/screen/login.screen.dart';
import 'package:knesset_odata/screen/member.screen.dart';
import 'package:knesset_odata/screen/start.screen.dart';
import 'package:knesset_odata/service/firebase.service.dart';
import 'model/redux/reducer/app.reducer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MainApp());

class MainApp extends StatefulWidget {
  final String local = "he";

  final store = Store<AppState>(appReducer,
      initialState: new AppState.initial(), middleware: [thunkMiddleware]);
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: widget.store,
      child: new StoreConnector<AppState, StartViewModel>(
          converter: (store) => StartViewModel.fromStore(store),
          builder: (_, viewModel) => AppView(viewModel)),
    );
  }
}

class AppView extends StatefulWidget {
  final String title = "טוען נתונים";
  final StartViewModel viewModel;

  AppView(this.viewModel);

  @override
  _AppViewState createState() => _AppViewState();
  _firebaseToken(String token) {
    viewModel.firebaseToken(token);
  }

  _message(Map<String, dynamic> message) {}
  _resume(Map<String, dynamic> message) {}
  _launch(Map<String, dynamic> message) {}
}

class _AppViewState extends State<AppView> {
  FireBaseService firebaseService;

  _firebaseCloudMessagingListeners(StartViewModel viewModel) {
    viewModel.loadConfig();
    firebaseService = new FireBaseService(
        onFirebaseToken: widget._firebaseToken,
        onMessage: widget._message,
        onResume: widget._resume,
        onLaunch: widget._launch);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: new StoreConnector<AppState, StartViewModel>(
            converter: (store) => StartViewModel.fromStore(store),
            builder: (_, viewModel) => buildContent(viewModel)));
  }

  buildContent(StartViewModel viewModel) {
    return MaterialApp(
      locale: Locale(viewModel.language),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale("en"), Locale("he")],
      title: 'Show The Truth',
      navigatorKey: Keys.navKey,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: StartScreen(
          title: "${widget.title}...",
          loadFirebase: _firebaseCloudMessagingListeners),
      routes: {
        Routes.homeScreen: (context) {
          return HomeScreen();
        },
        Routes.loginScreen: (context) {
          return LoginScreen(title: 'Log in');
        },
        Routes.memberScreen: (context) {
          return MemberScreen();
        },
        Routes.timeScreen: (context) {
          return TimeScreen();
        }
      },
    );
  }
}
