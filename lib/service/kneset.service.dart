//https://knesset.gov.il/WebSiteApi/knessetapi/MKs/GetMksPrevious
//https://knesset.gov.il/WebSiteApi/knessetapi/MKs/GetMks?IsCurrentKnesset=true

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/redux/action/screen.action.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';

class LoadKnesetDataAction {
  final KnessetFilter knessetFilter;
  final List<dynamic> knessetMember;
  final List<KnessetAttendanceData> knessetAttendance;

  LoadKnesetDataAction(
      this.knessetFilter, this.knessetMember, this.knessetAttendance);
}

ThunkAction<AppState> loadKnesetData() {
  return (Store<AppState> store) async {
    new Future(() async {
      try {
        final Map appData = await filetToMap("assets/kneset/app.data.v1.json");
        final KnessetFilter knessetFilter = KnessetFilter.fromJson(appData);
        final List<dynamic> knessetMember = appData["member"]
            .entries
            .map((e) => KnesetMember.fromJson(e.value))
            .toList();

        final Map attendance = appData["attendance"];
        final List<KnessetAttendanceData> knessetAttendance = [];

        attendance["knessetAttendance"].forEach((value) =>
            knessetAttendance.add(KnessetAttendanceData.fromJson(value)));

        store.dispatch(new LoadKnesetDataAction(
            knessetFilter, knessetMember, knessetAttendance));
      } catch (e) {
        print(e);
      }
    });
  };
}
