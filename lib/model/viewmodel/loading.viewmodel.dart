import 'package:redux/redux.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';

class LoadingViewModel {
  final int isLoading;

  LoadingViewModel({this.isLoading});

  static LoadingViewModel fromStore(Store<AppState> store) {
    return LoadingViewModel(isLoading: store.state.configState.isLoading);
  }
}
