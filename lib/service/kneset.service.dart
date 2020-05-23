import 'package:knesset_odata/model/redux/action/config.action.dart';
import 'package:knesset_odata/util/odata.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/redux/action/screen.action.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';

class LoadKnesetDataAction {
  final KnessetFilter knessetFilter;
  final List<dynamic> knessetMember;
  final List<KnessetAttendanceData> knessetAttendance;
  final ODataBill knessetMemberBill;
  final ODataBillLaw knessetLaw;

  LoadKnesetDataAction(this.knessetFilter, this.knessetMember,
      this.knessetAttendance, this.knessetMemberBill, this.knessetLaw);
}

ThunkAction<AppState> loadLawData() {
  return (Store<AppState> store) async {
    new Future(() async {
      try {
        ODataBillLaw current = store.state.knessetState.knessetLaw;
        if (current != null) return;
        store.dispatch(new StartLoadingAction(2));
        final String statusXml = await getFileData("assets/kneset/status.xml");
        OData status = parseOData(statusXml);
        Map<int, String> statusDic = {};
        status.items.forEach((element) {
          statusDic[element["d:StatusID"]] =
              element["d:Desc"] ?? element["d:TypeDesc"];
        });
        Map memberDic = {};
        List member = store.state.knessetState.knessetMember;
        member.forEach((element) {
          memberDic[element.personID] = element;
        });

        OData odata = OData([], "");
        ODataBillLaw knessetLaw = ODataBillLaw(odata, statusDic, memberDic);

        store.dispatch(new LoadKnesetDataAction(
            store.state.knessetState.knessetFilter,
            store.state.knessetState.knessetMember,
            store.state.knessetState.knessetAttendance,
            store.state.knessetState.knessetMemberBill,
            knessetLaw));
        store.dispatch(new StartLoadingAction(0));
      } catch (e) {
        print(e);
      }
    });
  };
}

ThunkAction<AppState> loadBillData() {
  return (Store<AppState> store) async {
    new Future(() async {
      try {
        ODataBill current = store.state.knessetState.knessetMemberBill;
        if (current != null) return;
        store.dispatch(new StartLoadingAction(2));
        final String statusXml = await getFileData("assets/kneset/status.xml");
        OData status = parseOData(statusXml);
        Map<int, String> statusDic = {};
        status.items.forEach((element) {
          statusDic[element["d:StatusID"]] =
              element["d:Desc"] ?? element["d:TypeDesc"];
        });
        Map memberDic = {};
        List member = store.state.knessetState.knessetMember;
        member.forEach((element) {
          memberDic[element.personID] = element;
        });

        OData odata = OData([], "");
        ODataBill knessetMemberBill = ODataBill(odata, statusDic, memberDic);

        //await knessetMemberBill.nextPage();

        store.dispatch(new LoadKnesetDataAction(
            store.state.knessetState.knessetFilter,
            store.state.knessetState.knessetMember,
            store.state.knessetState.knessetAttendance,
            knessetMemberBill,
            store.state.knessetState.knessetLaw));
        store.dispatch(new StartLoadingAction(0));
      } catch (e) {
        print(e);
      }
    });
  };
}

ThunkAction<AppState> loadKnesetData() {
  return (Store<AppState> store) async {
    new Future(() async {
      try {
        store.dispatch(new StartLoadingAction(2));
        store.dispatch(loadLanguageData());

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
            knessetFilter, knessetMember, knessetAttendance, null, null));

        store.dispatch(loadConfigState());
      } catch (e) {
        print(e);
      }
    });
  };
}
