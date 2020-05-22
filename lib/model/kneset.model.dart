Map filterNullValue(Map data) {
  return Map.fromIterable(
      data.entries
          .where(
              (e) => e.value != null && e.key != "FullName" && e.key != "MkID")
          .toList(),
      key: (v) => v.key,
      value: (v) => v.value);
}

List filterByMkId(int mkID, List data) {
  return data.where((f) => f["MkID"] == mkID).toList();
}

class KeyValue<T> {
  String name;
  T value;
  KeyValue(this.name, this.value);
}

List<KeyValue<int>> convert(List list, String name, String value) {
  List<KeyValue<int>> data = [];
  list.forEach((item) => data.add(KeyValue<int>(item[name], item[value])));
  return data;
}

List<KeyValue<String>> convertStringList(List list) {
  List<KeyValue<String>> data = [];
  list.forEach((value) => data.add(KeyValue<String>("$value", value)));
  return data;
}

List<KeyValue<int>> convertIntList(List list) {
  List<KeyValue<int>> data = [];
  list.forEach((value) => data.add(KeyValue<int>("$value", int.parse(value))));
  return data;
}

class KnessetFilter {
  List birthCountry;
  List cityName;
  List gender;
  List firstLetter;
  List knessetId;
  List faction;
  List year;

  KnessetFilter.fromJson(Map appData)
      : birthCountry = convertStringList(appData["filters"]["birthCountry"]),
        cityName = convertStringList(appData["filters"]["cityName"]),
        gender = convertStringList(appData["filters"]["gender"]),
        firstLetter = convertStringList(appData["filters"]["firstLetter"]),
        knessetId = convertIntList(appData["filters"]["knessetId"]),
        faction = convertStringList(appData["filters"]["faction"]),
        year = convertIntList(appData["filters"]["year"]);
}

class KnessetAttendanceData {
  Map data;
  /*
  String knessetNum;
  int total;
  int member;
  double ratio;*/
  KnessetAttendanceData.fromJson(Map member) : data = member;
}

class KnesetMember {
  int age;
  String birthCountry;
  DateTime birthDate;
  String cityName;
  DateTime deathDate;
  String firstLetter;
  String fullName;
  String gender;
  String imgPath;
  List knessetNums;
  Map positions;
  int positionCount;
  Map stats;
  double stars;
  int total;
  int totalDone;
  Map knessetAttendance;
  int personID;

  KnesetMember.fromJson(Map member)
      : age = member['age'] ?? 0,
        birthCountry = member['birthCountry'] ?? "",
        birthDate = member['birthDate'] != null
            ? DateTime.parse(member['birthDate'])
            : member['birthDate'],
        cityName = member['cityName'] ?? "",
        deathDate = member['deathDate'] != null
            ? DateTime.parse(member['deathDate'])
            : member['deathDate'],
        firstLetter = member['firstLetter'] ?? "",
        fullName = member['fullName'],
        gender = member['gender'] ?? "",
        imgPath = member['imgPath'] ?? "",
        knessetNums = member['knessetNums'] ?? [],
        positions = member['positions'] ?? {},
        positionCount = member['positionCount'] ?? 0,
        stats = member['stats'] ?? {},
        stars = 1.0 * member['stars'] ?? 0.0,
        total = member['total'] ?? 0,
        totalDone = member['totalDone'] ?? 0,
        knessetAttendance = member['knessetAttendance'] ?? {},
        personID = int.parse(member['personID']) ?? 0;
}
