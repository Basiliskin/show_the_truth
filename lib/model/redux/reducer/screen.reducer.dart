import 'package:redux/redux.dart';
import 'package:knesset_odata/model/redux/action/screen.action.dart';
import 'package:knesset_odata/model/redux/state/screen.state.dart';

final screenReducer = combineReducers<ScreenState>(
    [TypedReducer<ScreenState, LoadDataAction>(_loadDataAction)]);
ScreenState _loadDataAction(ScreenState state, LoadDataAction action) {
  return state.copyWith(data: action.data);
}
