import 'dart:math';

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

final _random = new Random();
int next(int min, int max) => min + _random.nextInt(max - min);

class BillScreen extends ScreenComponet<ScreenViewModel> {
  BillScreen({Key key}) : super(key: key, screenName: Routes.billScreen);
  @override
  ScreenViewModel viewCreator(Store<AppState> store) {
    return ScreenViewModel.fromStore(store);
  }

  Future<List<dynamic>> nextPageCallback(
      int mode, ODataBill knessetMemberBill) async {
    if (knessetMemberBill == null) return [];
    if (mode == 1) knessetMemberBill.reset();
    List<BillListItem> tmp = await knessetMemberBill.nextPage();
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
    final ODataBill knessetMemberBill = knessetState.knessetMemberBill;
    return Expanded(
        child: LazyList((int mode) async =>
            await nextPageCallback(mode, knessetMemberBill)));
  }
}
