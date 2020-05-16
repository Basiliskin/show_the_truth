import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/redux/action/config.action.dart';

typedef bool FilterCallback(String name, KnesetMember member);

class UpdateIndexesAction {
  final List<int> indexes;

  UpdateIndexesAction(this.indexes);
}

ThunkAction<AppState> updateIndexes(Map<String, bool> filter) {
  return (Store<AppState> store) async {
    List<int> indexes = [];
    List<MapEntry<String, bool>> selected =
        filter.entries.where((e) => e.value).toList();
    List<String> attr;
    List member = store.state.knessetState.knessetMember;

    Map<int, dynamic> mm = member.asMap();
    if (selected.length > 0) {
      Map<String, Map<String, bool>> knesset = store.state.configState.knesset;
      Map<String, Map<String, bool>> knessetYears =
          store.state.configState.knessetYears;
      Map<String, Map<String, bool>> faction = store.state.configState.faction;
      if (knesset == null || knessetYears == null || faction == null) {
        knesset = {};
        knessetYears = {};
        faction = {};
        member.forEach((m) => {
              knesset[m.fullName] = {},
              knessetYears[m.fullName] = {},
              faction[m.fullName] = {},
              if (m.positions != null)
                m.positions.entries.forEach((y) => {
                      y.value.forEach(
                          (p) => faction[m.fullName]["${p["Name"]}"] = true),
                    }),
              m.knessetNums.forEach((y) => {knesset[m.fullName]["$y"] = true}),
            });
        store.dispatch(
            new UpdateIndexesFilterAction(knesset, knessetYears, faction));
      }

      FilterCallback cb;
      final Map<String, FilterCallback> filterFunction = {
        "stars": (String name, KnesetMember member) {
          double star = double.parse(name.replaceAll("+", ""));
          return (star == 4 && member.stars >= star ||
              member.stars >= star && member.stars < star + 1);
        },
        "fullName": (String name, KnesetMember member) {
          return member.fullName == name;
        },
        "birthCountry": (String name, KnesetMember member) {
          return member.birthCountry == name;
        },
        "cityName": (String name, KnesetMember member) {
          return member.cityName == name;
        },
        "firstLetter": (String name, KnesetMember member) {
          return member.firstLetter == name;
        },
        "gender": (String name, KnesetMember member) {
          return member.gender == name;
        },
        "knesset": (String name, KnesetMember member) {
          return knesset[member.fullName].containsKey(name);
        },
        "knessetYears": (String name, KnesetMember member) {
          return knessetYears[member.fullName].containsKey(name);
        },
        "faction": (String name, KnesetMember member) {
          return faction[member.fullName].containsKey(name);
        },
      };
      Map<String, List<String>> keyWord = {};
      Map<int, int> found = {};
      mm.forEach((index, value) => found[index] = 1);

      selected.forEach((f) => {
            attr = f.key.split("|"),
            keyWord[attr[0]] = keyWord[attr[0]] ?? [],
            keyWord[attr[0]].add(attr[1])
          });
      keyWord.entries.forEach((f) => {
            cb = filterFunction.containsKey(f.key)
                ? filterFunction[f.key]
                : null,
            if (cb != null)
              {
                f.value.forEach((word) => {
                      mm.forEach((index, value) => found[index] =
                          found[index] < 3 && cb(word, value) ? 2 : 3)
                    })
              }
          });
      found.entries.forEach((e) => {if (e.value == 2) indexes.add(e.key)});
    } else {
      mm.forEach((index, value) => indexes.add(index));
    }
    store.dispatch(new UpdateIndexesAction(indexes));
  };
}
