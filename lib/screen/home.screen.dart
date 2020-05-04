import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import 'package:knesset_odata/component/screen.componet.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/list.model.dart';
import 'package:knesset_odata/model/navigation.model.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/redux/state/knesset.state.dart';
import 'package:knesset_odata/model/viewmodel/screen.viewmodel.dart';

class HomeScreen extends ScreenComponet<ScreenViewModel> {
  final List<ListItem> items = [];

  HomeScreen({Key key}) : super(key: key, screenName: Routes.homeScreen);

  load(ScreenViewModel viewModel) {
    final KnessetState knessetState = viewModel.knessetState;
    final List<int> indexes = knessetState.indexes;
    final List knessetMember = knessetState.knessetMember;
    KnesetMember member;
    items.clear();
    indexes.forEach((i) =>
        {member = knessetMember[i], items.add(KnesetMemberItem(member))});
  }

  @override
  buildScreen(ScreenViewModel viewModel, dynamic arguments,
      BoxConstraints viewportConstraints) {
    load(viewModel);
    return Expanded(
      child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return new GestureDetector(
                //You need to make my child interactive
                onTap: () => {
                      Navigator.pushNamed(context, Routes.memberScreen,
                          arguments: item)
                    },
                child: new Card(
                    //I am the clickable child
                    child: item.buildItem(context)));
            //return item.buildItem(context);
          }),
    );
  }

  @override
  ScreenViewModel viewCreator(Store<AppState> store) {
    return ScreenViewModel.fromStore(store);
  }
}
