import 'dart:async';

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
  final changeNotifier = new StreamController.broadcast();
  LawScreen({Key key}) : super(key: key, screenName: Routes.lawScreen);
  @override
  deinit() {
    changeNotifier.close();
  }

  @override
  ScreenViewModel viewCreator(Store<AppState> store) {
    return ScreenViewModel.fromStore(store);
  }

  @override
  searchQueryValue(value) {
    changeNotifier.sink.add(value);
  }

  @override
  searchReset() {
    changeNotifier.sink.add("");
  }

  Future<List<dynamic>> nextPageCallback(
      ScreenViewModel viewModel, int mode, ODataBillLaw knessetLaw) async {
    if (knessetLaw == null) return [];
    viewModel.setLoading(true);
    if (mode == 1) knessetLaw.reset();
    List<BillListItem> tmp = await knessetLaw.nextPage();
    List<BillListItemData> items = [];
    tmp.forEach((element) {
      items.add(new BillListItemData(element.bill, element.members));
    });
    viewModel.setLoading(false);
    return items;
  }

  searchCallback(String value, ODataBillLaw knessetMemberBill) async {
    if (knessetMemberBill == null) return;
    knessetMemberBill.search(value);
  }

  @override
  buildScreen(ScreenViewModel viewModel, BuildContext context,
      BoxConstraints viewportConstraints) {
    final KnessetState knessetState = viewModel.knessetState;
    final ODataBillLaw knessetMemberBill = knessetState.knessetLaw;
    final onUpdate = (int mode) async =>
        await nextPageCallback(viewModel, mode, knessetMemberBill);
    final onSearch = (String value) => searchCallback(value, knessetMemberBill);
    return Expanded(child: LazyList(onUpdate, changeNotifier.stream, onSearch));
  }
}
