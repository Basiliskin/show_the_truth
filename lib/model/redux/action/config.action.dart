import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knesset_odata/model/navigation.model.dart';
import 'package:knesset_odata/model/redux/action/app.action.dart';
import 'package:knesset_odata/model/redux/action/knesset.action.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/redux/state/config.state.dart';

ThunkAction<AppState> updateConfigState(Map<String, dynamic> item) {
  return (Store<AppState> store) async {
    final Map<String, dynamic> newMap = {}
      ..addAll(store.state.configState.data)
      ..addAll(item);
    store.dispatch(new UpdateDataAction(newMap));
  };
}

ThunkAction<AppState> changeLanguage(String language) {
  return (Store<AppState> store) async {
    new Future(() async {
      store.dispatch(new StartLoadingAction(2));
      List<dynamic> languages =
          store.state.configState.data.containsKey("languages")
              ? store.state.configState.data["languages"]
              : [];
      final currentLanguage =
          languages.firstWhere((item) => item == language, orElse: () => null);
      if (currentLanguage == null) {
        store.dispatch(new ApplicationError("Invalid language"));
        store.dispatch(new LoadingCompleteAction());
        return;
      }
      store.dispatch(new MergeDataAction(language, {"language": language}));
      Future.delayed(Duration(seconds: 3), () {
        store.dispatch(new LoadingCompleteAction());
      });
    });
  };
}

ThunkAction<AppState> updateFilter(Map<String, bool> filters) {
  return (Store<AppState> store) async {
    new Future(() async {
      store.dispatch(new StartLoadingAction(2));
      store.dispatch(new UpdateFilter(filters));
      store.dispatch(updateIndexes(filters));
      Future.delayed(Duration(seconds: 1), () {
        store.dispatch(new LoadingCompleteAction());
      });
    });
  };
}

ThunkAction<AppState> resetFilter() {
  return (Store<AppState> store) async {
    new Future(() async {
      store.dispatch(new StartLoadingAction(2));
      store.dispatch(new UpdateFilter({}));
      store.dispatch(updateIndexes({}));
      Future.delayed(Duration(seconds: 1), () {
        store.dispatch(new LoadingCompleteAction());
      });
    });
  };
}

ThunkAction<AppState> loadConfigState() {
  return (Store<AppState> store) async {
    new Future(() async {
      store.dispatch(new StartLoadingAction(2));
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var string = preferences.getString(prefsName);
      Map<String, dynamic> data = defaultConfig;
      if (string != null) {
        data = json.decode(string);
      }
      Map<String, dynamic> config = Map.from(data);
      // get public server key
      Map<String, dynamic> publicKey = MOKING_ENABLED
          ? {
              "publivKey":
                  "241,20,166,166,249,153,135,69,231,173,15,156,153,179,131,201,184,35,135,152,215,211,198,181,15,198,80,81,147,207,115,54"
            }
          : await store.state
              .request('/server/publicKey', {"header": {}, "payload": {}});
      // languages
      final List<String> _languages =
          store.state.screenState.data.entries.map((e) => e.key).toList();
      if (config["language"] == null)
        config["language"] = _languages[0];
      else {
        final currentLanguage = _languages.firstWhere(
            (lang) => lang == config["language"],
            orElse: () => null);
        if (currentLanguage == null) config["language"] = _languages[0];
      }

      final Map<String, dynamic> newMap = {}
        ..addAll(config)
        ..addAll({
          "language": config["language"],
          "serverPublicKey": publicKey["publivKey"],
          "languages": _languages
        });

      store.dispatch(new LoadingSuccessAction(config["language"], newMap));
      store.dispatch(new LoadingCompleteAction());
      Keys.navKey.currentState.pushReplacementNamed(Routes.homeScreen);
    });
  };
}

class StartLoadingAction {
  final int isLoading;
  StartLoadingAction(this.isLoading);
}

class UpdateFilter {
  final Map<String, bool> filter;
  UpdateFilter(this.filter);
}

class UpdateIndexesFilterAction {
  final Map<String, Map<String, bool>> knesset;
  final Map<String, Map<String, bool>> knessetYears;
  final Map<String, Map<String, bool>> faction;

  UpdateIndexesFilterAction(this.knesset, this.knessetYears, this.faction);
}

class LoadingSuccessAction {
  final String language;
  final Map<String, dynamic> data;

  LoadingSuccessAction(this.language, this.data);
}

class LoadingCompleteAction {
  LoadingCompleteAction();
}

class UpdateDataAction {
  final Map<String, dynamic> data;

  UpdateDataAction(this.data);
}

class MergeDataAction {
  final String language;
  final Map<String, dynamic> data;

  MergeDataAction(this.language, this.data);
}

class LoginFailedAction {
  final String errorMessage;
  LoginFailedAction(this.errorMessage);
}
