//https://knesset.gov.il/WebSiteApi/knessetapi/MKs/GetMksPrevious
//https://knesset.gov.il/WebSiteApi/knessetapi/MKs/GetMks?IsCurrentKnesset=true

import 'dart:convert';

import 'package:knesset_odata/model/redux/action/config.action.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/redux/action/screen.action.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:xml2json/xml2json.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class LoadKnesetDataAction {
  final KnessetFilter knessetFilter;
  final List<dynamic> knessetMember;
  final List<KnessetAttendanceData> knessetAttendance;
  final List<dynamic> knessetMemberBill;

  LoadKnesetDataAction(this.knessetFilter, this.knessetMember,
      this.knessetAttendance, this.knessetMemberBill);
}

Map convertODataValue(Map item) {
  Map data = {};
  item.entries.forEach((element) {
    if (element.value.containsKey("@m:null")) {
    } else {
      String type = element.value["@m:type"];
      dynamic val = element.value["\$"];

      switch (type) {
        case "Edm.DateTime":
          val = DateFormat('yyyy-MM-dd').parse(val);
          break;
        case "Edm.Int32":
          val = int.parse(val);
          break;
        case "Edm.Boolean":
          val = val == "true";
          break;
      }
      data[element.key] = val;
    }
  });
  return data;
}

class OData {
  List<dynamic> items;
  String nextLink;
  OData(this.items, this.nextLink);
  Future<bool> next() async {
    http.Client _client = http.Client();

    if (nextLink != "") {
      var url = Uri.parse(nextLink);
      var res = await _client.get(url);
      OData tmp = parseOData(res.body);
      items.addAll(tmp.items);
      return true;
    }
    return false;
  }
}

OData parseOData(String xml) {
  final myTransformer = Xml2Json();
  myTransformer.parse(xml);
  dynamic json = myTransformer.toBadgerfish();
  Map<dynamic, dynamic> map = jsonDecode(json);
  Map<dynamic, dynamic> feed = map["feed"];
  List<dynamic> link = (feed["link"] is List) ? feed["link"] : [feed["link"]];
  Map next = link.firstWhere((element) => element["@rel"] == "next",
      orElse: () => null);
  String nextLink = "";
  if (next != null) {
    nextLink = next["@href"];
  }
  List<dynamic> entry = feed["entry"];
  List<dynamic> list = [];
  entry.forEach((element) {
    Map properties = element["content"]["m:properties"];
    Map item = {}..addAll(properties);
    List<dynamic> link = element["link"];

    link.forEach((l) {
      if (l.containsKey("m:inline")) {
        Map props = l["m:inline"]["entry"]["content"]["m:properties"];
        item.addAll(props);
      }
    });
    list.add(convertODataValue(item));
  });
  return OData(list, nextLink);
}

ThunkAction<AppState> loadBillData() {
  return (Store<AppState> store) async {
    new Future(() async {
      try {
        List<dynamic> current = store.state.knessetState.knessetMemberBill;
        if (current.length > 0) return;
        store.dispatch(new StartLoadingAction(2));
        final String statusXml = await getFileData("assets/kneset/status.xml");
        OData status = parseOData(statusXml);

        http.Client _client = http.Client();
        var url = Uri.parse(
            "http://knesset.gov.il/Odata/ParliamentInfo.svc/KNS_BillInitiator()?\$expand=KNS_Bill&\$orderby=LastUpdatedDate%20desc");
        var res = await _client.get(url);
        final String billXml =
            res.body; //await getFileData("assets/kneset/bills.xml");
        OData knessetMemberBill;
        knessetMemberBill = parseOData(billXml);
        int pages = 3;
        while (pages > 0) {
          var r = await knessetMemberBill.next();
          if (r == false) break;
          pages--;
        }
        Map<int, String> statusDic = {};
        status.items.forEach((element) {
          statusDic[element["d:StatusID"]] = element["d:TypeDesc"];
        });
        Map memberDic = {};
        List member = store.state.knessetState.knessetMember;
        member.forEach((element) {
          memberDic[element.personID] = element;
        });
        knessetMemberBill.items.forEach((element) {
          element["info"] = memberDic[element["d:PersonID"]];
          element["d:StatusTypeDesc"] = statusDic[element["d:StatusID"]];
        });

        store.dispatch(new LoadKnesetDataAction(
            store.state.knessetState.knessetFilter,
            store.state.knessetState.knessetMember,
            store.state.knessetState.knessetAttendance,
            knessetMemberBill.items));
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
            knessetFilter, knessetMember, knessetAttendance, []));

        store.dispatch(loadConfigState());
      } catch (e) {
        print(e);
      }
    });
  };
}
