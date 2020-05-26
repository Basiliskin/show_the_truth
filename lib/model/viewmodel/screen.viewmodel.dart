import 'package:redux/redux.dart';
import 'package:knesset_odata/model/redux/action/config.action.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/redux/state/knesset.state.dart';
import 'package:knesset_odata/service/kneset.service.dart';

typedef S ScreenViewModelFromStore<S>(Store<AppState> store);

class ScreenViewModel {
  final String language;
  final int isLoading;
  final String errorMessage;
  final Map<String, dynamic> data;
  final Map<String, dynamic> screenData;
  final KnessetState knessetState;
  final Map<String, bool> filter;

  final Function() loadConfig;
  final Function(String token) firebaseToken;
  final Function(String language) changeCurrentLanguage;
  final Function(Map<String, bool> filters) onFilterUpdate;
  final Function() onResetFilter;
  final Function() loadBill;
  final Function() loadLaw;
  final Function(bool loading) setLoading;

  ScreenViewModel(
      {this.isLoading,
      this.errorMessage,
      this.data,
      this.loadConfig,
      this.firebaseToken,
      this.language,
      this.changeCurrentLanguage,
      this.screenData,
      this.knessetState,
      this.onFilterUpdate,
      this.filter,
      this.onResetFilter,
      this.loadBill,
      this.loadLaw,
      this.setLoading});

  static ScreenViewModel fromStore(Store<AppState> store) {
    return ScreenViewModel(
        language: store.state.configState.language,
        isLoading: store.state.configState.isLoading,
        errorMessage: store.state.configState.errorMessage,
        data: store.state.configState.data,
        knessetState: store.state.knessetState,
        screenData: store.state.screenState != null
            ? store.state.screenState.screen(store.state.configState.language)
            : null,
        changeCurrentLanguage: (String language) {
          store.dispatch(changeLanguage(language));
        },
        onFilterUpdate: (Map<String, bool> filters) {
          store.dispatch(updateFilter(filters));
        },
        onResetFilter: () {
          store.dispatch(resetFilter());
        },
        loadBill: () {
          store.dispatch(loadBillData());
        },
        loadLaw: () {
          store.dispatch(loadLawData());
        },
        setLoading: (bool loading) {
          store.dispatch(new StartLoadingAction(loading ? 2 : 0));
        },
        filter: store.state.configState.filter);
  }
}
