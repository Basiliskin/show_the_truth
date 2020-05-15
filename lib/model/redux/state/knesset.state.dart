import 'package:meta/meta.dart';
import 'package:knesset_odata/model/kneset.model.dart';

@immutable
class KnessetState {
  final KnessetFilter knessetFilter;
  final List<dynamic> knessetMember;
  final List<int> indexes;
  final List<KnessetAttendanceData> knessetAttendance;

  KnessetState(
      {@required this.knessetFilter,
      @required this.knessetMember,
      @required this.indexes,
      @required this.knessetAttendance});

  factory KnessetState.initial() {
    return new KnessetState(
        knessetFilter: null,
        knessetMember: null,
        indexes: [],
        knessetAttendance: null);
  }

  KnessetState copyWith(
      {KnessetFilter knessetFilter,
      List<dynamic> knessetMember,
      List<int> indexes,
      List<dynamic> knessetAttendance}) {
    return new KnessetState(
        knessetMember: knessetMember ?? this.knessetMember,
        knessetFilter: knessetFilter ?? this.knessetFilter,
        indexes: indexes ?? this.indexes,
        knessetAttendance: knessetAttendance ?? this.knessetAttendance);
  }
}
