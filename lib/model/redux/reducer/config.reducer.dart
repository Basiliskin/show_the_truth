import 'package:redux/redux.dart';
import 'package:knesset_odata/model/redux/action/app.action.dart';
import 'package:knesset_odata/model/redux/action/config.action.dart';
import 'package:knesset_odata/model/redux/state/config.state.dart';

final configReducer = combineReducers<ConfigState>([
  TypedReducer<ConfigState, MergeDataAction>(_mergeData),
  TypedReducer<ConfigState, UpdateDataAction>(_updateData),
  TypedReducer<ConfigState, LoadingSuccessAction>(_loadingSuccess),
  TypedReducer<ConfigState, LoginFailedAction>(_loginFailed),
  TypedReducer<ConfigState, StartLoadingAction>(_startLoading),
  TypedReducer<ConfigState, ApplicationError>(_errorMessage),
  TypedReducer<ConfigState, LoadingCompleteAction>(_loadinComplete),
  TypedReducer<ConfigState, UpdateFilter>(_updateFilter),
  TypedReducer<ConfigState, UpdateIndexesFilterAction>(_updateFilterIndexes),
]);
ConfigState _loadinComplete(ConfigState state, LoadingCompleteAction action) {
  return state.copyWith(isLoading: 0, errorMessage: "");
}

ConfigState _errorMessage(ConfigState state, ApplicationError action) {
  return state.copyWith(errorMessage: action.errorMessage);
}

ConfigState _loadingSuccess(ConfigState state, LoadingSuccessAction action) {
  return state.copyWith(language: action.language, data: action.data);
}

ConfigState _updateData(ConfigState state, UpdateDataAction action) {
  return state.copyWith(data: action.data);
}

ConfigState _mergeData(ConfigState state, MergeDataAction action) {
  final Map<String, dynamic> newData = {}
    ..addAll(state.data)
    ..addAll(action.data);
  return state.copyWith(language: action.language, data: newData);
}

ConfigState _loginFailed(ConfigState state, LoginFailedAction action) {
  return state.copyWith(
      data: null, isLoading: 0, errorMessage: action.errorMessage);
}

ConfigState _startLoading(ConfigState state, StartLoadingAction action) {
  return state.copyWith(isLoading: action.isLoading, errorMessage: "");
}

ConfigState _updateFilter(ConfigState state, UpdateFilter action) {
  return state.copyWith(filter: action.filter);
}

ConfigState _updateFilterIndexes(
    ConfigState state, UpdateIndexesFilterAction action) {
  return state.copyWith(
      knesset: action.knesset,
      knessetYears: action.knessetYears,
      faction: action.faction);
}
