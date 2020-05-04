import 'package:redux/redux.dart';
import 'package:knesset_odata/model/redux/action/config.action.dart';
import 'package:knesset_odata/model/redux/action/screen.action.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/service/kneset.service.dart';

class StartViewModel {
  final String language;
  final int isLoading;
  final String errorMessage;
  final Map<String, dynamic> data;
  final Map<String, dynamic> screenData;

  final Function() loadConfig;
  final Function(String token) firebaseToken;

  StartViewModel(
      {this.isLoading,
      this.errorMessage,
      this.data,
      this.loadConfig,
      this.firebaseToken,
      this.language,
      this.screenData});

  static StartViewModel fromStore(Store<AppState> store) {
    return StartViewModel(
        language: store.state.configState.language,
        isLoading: store.state.configState.isLoading,
        errorMessage: store.state.configState.errorMessage,
        data: store.state.configState.data,
        screenData: store.state.screenState != null
            ? store.state.screenState.screen(store.state.configState.language)
            : null,
        loadConfig: () {
          store.dispatch(loadLanguageData());
          store.dispatch(loadKnesetData());
          store.dispatch(loadConfigState());
        },
        firebaseToken: (String token) {
          print("firebaseMessaging: $token");
          store.dispatch(updateConfigState({"firebaseToken": token}));
        });
  }
}
