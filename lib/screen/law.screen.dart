import 'package:flutter/material.dart';
import 'package:knesset_odata/component/bill.component.dart';
import 'package:knesset_odata/component/lazy.loading.list.dart';
import 'package:knesset_odata/component/screen.componet.dart';
import 'package:knesset_odata/model/navigation.model.dart';
import 'package:knesset_odata/model/redux/state/knesset.state.dart';
import 'package:knesset_odata/model/viewmodel/screen.viewmodel.dart';
import 'package:knesset_odata/util/odata.dart';
import 'package:redux/redux.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';

class LawScreen extends ScreenComponet<ScreenViewModel> {
  LawScreen({Key key}) : super(key: key, screenName: Routes.lawScreen);
  @override
  ScreenViewModel viewCreator(Store<AppState> store) {
    return ScreenViewModel.fromStore(store);
  }

  Future<List<dynamic>> nextPageCallback(
      int mode, ODataBillLaw knessetLaw) async {
    if (knessetLaw == null) return [];
    if (mode == 1) knessetLaw.reset();
    List<BillListItem> tmp = await knessetLaw.nextPage();
    List<BillListItemData> items = [];
    tmp.forEach((element) {
      items.add(new BillListItemData(element.bill, element.members));
    });
    return items;
  }

  @override
  buildScreen(ScreenViewModel viewModel, BuildContext context,
      BoxConstraints viewportConstraints) {
    final KnessetState knessetState = viewModel.knessetState;
    final ODataBillLaw knessetMemberBill = knessetState.knessetLaw;
    return Expanded(
        child: LazyList((int mode) async =>
            await nextPageCallback(mode, knessetMemberBill)));
  }
}
