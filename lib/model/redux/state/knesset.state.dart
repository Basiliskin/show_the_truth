import 'package:meta/meta.dart';
import 'package:knesset_odata/model/kneset.model.dart';

@immutable
class KnessetState {
  final KnessetFilter knessetFilter;
  final List<dynamic> knessetMember;
  final List<int> indexes;

  KnessetState(
      {@required this.knessetFilter,
      @required this.knessetMember,
      @required this.indexes});

  factory KnessetState.initial() {
    return new KnessetState(
        knessetFilter: null, knessetMember: null, indexes: []);
  }

  KnessetState copyWith(
      {KnessetFilter knessetFilter,
      List<dynamic> knessetMember,
      List<int> indexes}) {
    return new KnessetState(
        knessetMember: knessetMember ?? this.knessetMember,
        knessetFilter: knessetFilter ?? this.knessetFilter,
        indexes: indexes ?? this.indexes);
  }
}
