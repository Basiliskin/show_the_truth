import 'package:redux/redux.dart';
import 'package:knesset_odata/model/redux/action/knesset.action.dart';
import 'package:knesset_odata/model/redux/state/knesset.state.dart';
import 'package:knesset_odata/service/kneset.service.dart';

final knessetReducer = combineReducers<KnessetState>([
  TypedReducer<KnessetState, UpdateIndexesAction>(_updateIndexesAction),
  TypedReducer<KnessetState, LoadKnesetDataAction>(_loadKnesetDataAction)
]);

KnessetState _loadKnesetDataAction(
    KnessetState state, LoadKnesetDataAction action) {
  List<int> indexes = [];
  action.knessetMember.asMap().forEach((index, value) => indexes.add(index));
  return state.copyWith(
      indexes: indexes,
      knessetFilter: action.knessetFilter,
      knessetMember: action.knessetMember,
      knessetAttendance: action.knessetAttendance,
      knessetMemberBill: action.knessetMemberBill,
      knessetLaw: action.knessetLaw);
}

KnessetState _updateIndexesAction(
    KnessetState state, UpdateIndexesAction action) {
  return state.copyWith(indexes: action.indexes);
}
