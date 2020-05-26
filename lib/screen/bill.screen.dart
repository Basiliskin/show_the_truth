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

class BillScreen extends ScreenComponet<ScreenViewModel> {
  final changeNotifier = new StreamController.broadcast();
  BillScreen({Key key}) : super(key: key, screenName: Routes.billScreen);

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
      ScreenViewModel viewModel, int mode, ODataBill knessetMemberBill) async {
    if (knessetMemberBill == null) return [];
    viewModel.setLoading(true);
    if (mode == 1) knessetMemberBill.reset();
    List<BillListItem> tmp = await knessetMemberBill.nextPage();
    List<BillListItemData> items = [];
    tmp.forEach((element) {
      items.add(new BillListItemData(element.bill, element.members));
    });
    viewModel.setLoading(false);
    return items;
  }

  searchCallback(String value, ODataBill knessetMemberBill) async {
    if (knessetMemberBill == null) return;
    knessetMemberBill.search(value);
  }

  @override
  buildScreen(ScreenViewModel viewModel, BuildContext context,
      BoxConstraints viewportConstraints) {
    final KnessetState knessetState = viewModel.knessetState;
    final ODataBill knessetMemberBill = knessetState.knessetMemberBill;
    final onUpdate = (int mode) async =>
        await nextPageCallback(viewModel, mode, knessetMemberBill);
    final onSearch = (String value) => searchCallback(value, knessetMemberBill);
    return Expanded(child: LazyList(onUpdate, changeNotifier.stream, onSearch));
  }
}
