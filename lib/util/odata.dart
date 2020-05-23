import 'dart:convert';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:xml2json/xml2json.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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
  setLink(String url) {
    nextLink = url;
  }

  init(String url) {
    items = [];
    nextLink = url;
  }
}

class BillListItem {
  final Map bill;
  final List<KnesetMember> members;
  BillListItem(this.bill, this.members);
  addMember(KnesetMember member) {
    KnesetMember exists = members.firstWhere(
        (element) => member.personID == element.personID,
        orElse: () => null);
    if (exists == null) members.add(member);
  }
}

class LawListItem {
  final Map law;
  LawListItem(this.law);
}

/*
class ODataLaw {
  String baseUrl =
      "http://knesset.gov.il/Odata/ParliamentInfo.svc/KNS_Law()?\$filter=KnessetNum%20ge%2017&\$orderby=KnessetNum%20desc,LastUpdatedDate%20desc,LawID%20desc";
  OData data;
  List<LawListItem> lawList = [];
  ODataLaw(this.data);
  reset() {
    data.init(baseUrl);
  }

  Future<List<LawListItem>> nextPage() async {
    http.Client _client = http.Client();
    List<LawListItem> result = [];
    if (data.items.length == 0 && data.nextLink == "") reset();
    if (data.nextLink != "") {
      var url = Uri.parse(data.nextLink);
      var res = await _client.get(url);
      OData tmp = parseOData(res.body);
      LawListItem item;
      var formatter = new DateFormat('dd/MM/yyyy');
      tmp.items.forEach((element) {
        element["LastUpdatedDate"] =
            formatter.format(element["d:LastUpdatedDate"]);
        element["PublicationDate"] =
            formatter.format(element["d:PublicationDate"]);
        item = LawListItem(element);
        lawList.add(item);
        result.add(item);
      });
      data.items.addAll(tmp.items);
      data.nextLink = tmp.nextLink;
    }
    return result;
  }
}
*/
class ODataBillLaw {
  String baseUrl =
      "http://knesset.gov.il/Odata/ParliamentInfo.svc/KNS_BillInitiator()?\$expand=KNS_Bill&\$filter=KNS_Bill/StatusID%20eq%20118&\$orderby=BillID%20desc";
  OData data;
  Map<int, String> statusDic;
  Map memberDic;
  Map<int, BillListItem> billList = {};
  ODataBillLaw(this.data, this.statusDic, this.memberDic);
  reset() {
    billList = {};
    data.init(baseUrl);
  }

  Future<List<BillListItem>> nextPage() async {
    http.Client _client = http.Client();
    List<BillListItem> result = [];
    if (data.items.length == 0 && data.nextLink == "") reset();
    if (data.nextLink != "") {
      var url = Uri.parse(data.nextLink);
      var res = await _client.get(url);
      OData tmp = parseOData(res.body);
      int billID;
      var formatter = new DateFormat('dd-MM-yyyy');
      tmp.items.forEach((element) {
        element["date"] = formatter.format(element["d:LastUpdatedDate"]);
        element["info"] = memberDic[element["d:PersonID"]];
        element["d:StatusTypeDesc"] = statusDic[element["d:StatusID"]];
        billID = element["d:BillID"];
        if (billList.containsKey(billID))
          billList[billID].addMember(element["info"]);
        else {
          billList[billID] = new BillListItem(element, [element["info"]]);
          result.add(billList[billID]);
        }
      });
      data.items.addAll(tmp.items);
      data.nextLink = tmp.nextLink;
    }
    return result;
  }
}

class ODataBill {
  String baseUrl =
      "http://knesset.gov.il/Odata/ParliamentInfo.svc/KNS_BillInitiator()?\$expand=KNS_Bill&\$orderby=BillID%20desc";
  OData data;
  Map<int, String> statusDic;
  Map memberDic;
  Map<int, BillListItem> billList = {};
  ODataBill(this.data, this.statusDic, this.memberDic);
  reset() {
    billList = {};
    data.init(baseUrl);
  }

  Future<List<BillListItem>> nextPage() async {
    http.Client _client = http.Client();
    List<BillListItem> result = [];
    if (data.items.length == 0 && data.nextLink == "") reset();
    if (data.nextLink != "") {
      var url = Uri.parse(data.nextLink);
      var res = await _client.get(url);
      OData tmp = parseOData(res.body);
      int billID;
      var formatter = new DateFormat('dd-MM-yyyy');
      tmp.items.forEach((element) {
        element["date"] = formatter.format(element["d:LastUpdatedDate"]);
        element["info"] = memberDic[element["d:PersonID"]];
        element["d:StatusTypeDesc"] = statusDic[element["d:StatusID"]];
        billID = element["d:BillID"];
        if (billList.containsKey(billID))
          billList[billID].addMember(element["info"]);
        else {
          billList[billID] = new BillListItem(element, [element["info"]]);
          result.add(billList[billID]);
        }
      });
      data.items.addAll(tmp.items);
      data.nextLink = tmp.nextLink;
    }
    return result;
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
