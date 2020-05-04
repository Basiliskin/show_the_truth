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

  LoadKnesetDataAction(this.knessetFilter, this.knessetMember);
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

        store.dispatch(new LoadKnesetDataAction(knessetFilter, knessetMember));
      } catch (e) {
        print(e);
      }
    });
  };
}
