import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:knesset_odata/model/redux/state/app.state.dart';

Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path);
}

Future<Map> filetToMap(String path) async {
  String data = await rootBundle.loadString(path);
  return json.decode(data);
}

class LoadDataAction {
  final Map data;
  LoadDataAction(this.data);
}

ThunkAction<AppState> loadLanguageData() {
  return (Store<AppState> store) async {
    new Future(() async {
      final String data = await getFileData("assets/language/data.json");
      if (data != null) {
        store.dispatch(new LoadDataAction(json.decode(data)));
      }
    });
  };
}
