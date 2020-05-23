import 'package:knesset_odata/util/odata.dart';
import 'package:meta/meta.dart';
import 'package:knesset_odata/model/kneset.model.dart';

@immutable
class KnessetState {
  final KnessetFilter knessetFilter;
  final List<dynamic> knessetMember;
  final List<int> indexes;
  final ODataBill knessetMemberBill;
  final List<KnessetAttendanceData> knessetAttendance;
  final ODataBillLaw knessetLaw;

  KnessetState(
      {@required this.knessetFilter,
      @required this.knessetMember,
      @required this.indexes,
      @required this.knessetAttendance,
      @required this.knessetMemberBill,
      @required this.knessetLaw});

  factory KnessetState.initial() {
    return new KnessetState(
        knessetFilter: null,
        knessetMember: null,
        indexes: [],
        knessetAttendance: null,
        knessetMemberBill: null,
        knessetLaw: null);
  }

  KnessetState copyWith(
      {KnessetFilter knessetFilter,
      List<dynamic> knessetMember,
      List<int> indexes,
      List<dynamic> knessetAttendance,
      ODataBill knessetMemberBill,
      ODataBillLaw knessetLaw}) {
    return new KnessetState(
        knessetMember: knessetMember ?? this.knessetMember,
        knessetFilter: knessetFilter ?? this.knessetFilter,
        indexes: indexes ?? this.indexes,
        knessetAttendance: knessetAttendance ?? this.knessetAttendance,
        knessetMemberBill: knessetMemberBill ?? this.knessetMemberBill,
        knessetLaw: knessetLaw ?? this.knessetLaw);
  }
}
