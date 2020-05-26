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

class ODataBaseBill {
  OData data;
  Map<int, String> statusDic;
  Map memberDic;
  Map<int, BillListItem> billList = {};
  DateFormat formatter = new DateFormat('dd-MM-yyyy');
  String query = "";
  ODataBaseBill(this.data, this.statusDic, this.memberDic);
  getBaseUrl() {
    return "";
  }

  search(value) async {
    query = value;
    if (value == "" || value == null) {
      reset();
    } else {
      billList = {};
      String url = getSearchUrl(value);
      data.init(url);
    }
  }

  reset() {
    if (query == "") {
      billList = {};
      data.init(getBaseUrl());
    }
  }

  handleItem(OData tmp) {
    List<BillListItem> result = [];
    return result;
  }

  getSearchUrl(value) {
    return "";
  }

  Future<List<BillListItem>> nextPage() async {
    http.Client _client = http.Client();
    List<BillListItem> result = [];
    if (data.items.length == 0 && data.nextLink == "") reset();
    if (data.nextLink != "") {
      var url = Uri.parse(data.nextLink);
      var res = await _client.get(url);
      OData tmp = parseOData(res.body);
      return handleItem(tmp);
    }
    return result;
  }
}

class ODataBillLaw extends ODataBaseBill {
  ODataBillLaw(OData data, Map<int, String> statusDic, Map memberDic)
      : super(data, statusDic, memberDic);
  @override
  getSearchUrl(value) {
    return "http://knesset.gov.il/Odata/ParliamentInfo.svc/KNS_BillInitiator()?\$expand=KNS_Bill&\$filter=KNS_Bill/StatusID eq 118 and substringof('$value', KNS_Bill/Name) eq true&\$orderby=BillID desc";
  }

  @override
  getBaseUrl() {
    return "http://knesset.gov.il/Odata/ParliamentInfo.svc/KNS_BillInitiator()?\$expand=KNS_Bill&\$filter=KNS_Bill/StatusID%20eq%20118&\$orderby=BillID%20desc";
  }

  @override
  handleItem(OData tmp) {
    List<BillListItem> result = [];
    int billID;
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
    return result;
  }
}

class ODataBill extends ODataBaseBill {
  ODataBill(OData data, Map<int, String> statusDic, Map memberDic)
      : super(data, statusDic, memberDic);
  @override
  getSearchUrl(value) {
    return "http://knesset.gov.il/Odata/ParliamentInfo.svc/KNS_BillInitiator()?\$expand=KNS_Bill&\$filter=substringof('$value', KNS_Bill/Name) eq true&\$orderby=BillID desc";
  }

  @override
  getBaseUrl() {
    return "http://knesset.gov.il/Odata/ParliamentInfo.svc/KNS_BillInitiator()?\$expand=KNS_Bill&\$orderby=BillID%20desc";
  }

  @override
  handleItem(OData tmp) {
    List<BillListItem> result = [];
    int billID;
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
  if (entry == null) return OData([], nextLink);
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
