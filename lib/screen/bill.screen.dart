import 'dart:math';

import 'package:flutter/material.dart';
import 'package:knesset_odata/component/screen.componet.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/list.model.dart';
import 'package:knesset_odata/model/navigation.model.dart';
import 'package:knesset_odata/model/redux/state/knesset.state.dart';
import 'package:knesset_odata/model/viewmodel/screen.viewmodel.dart';
import 'package:redux/redux.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';

final _random = new Random();
int next(int min, int max) => min + _random.nextInt(max - min);

const double imageSize = 32;

class ListItem {
  final Map bill;
  final List<KnesetMember> members;
  ListItem(this.bill, this.members);
  addMember(KnesetMember member) {
    KnesetMember exists = members.firstWhere(
        (element) => member.personID == element.personID,
        orElse: () => null);
    if (exists == null) members.add(member);
  }

  Widget buildImage(BuildContext context, KnesetMember member) =>
      GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            KnesetMemberItem m = new KnesetMemberItem(member);
            Navigator.pushNamed(context, Routes.memberScreen, arguments: m);
          },
          child: Container(
              width: imageSize,
              height: imageSize,
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: imageSize,
                  minHeight: imageSize,
                  maxWidth: imageSize,
                  maxHeight: imageSize,
                ),
                child: member.imgPath != ""
                    ? Image.network(member.imgPath, fit: BoxFit.cover)
                    : next(1, 5) % 2 == 1
                        ? Image.asset("assets/image/avatarB.png")
                        : Image.asset("assets/image/avatarA.png"),
              )));

  Widget buildDesc(BuildContext context) {
    //int billID = bill["d:BillID"];
    //int knessetNum = bill["d:KnessetNum"];
    String name = bill["d:Name"];
    //String status = bill["d:StatusTypeDesc"];
    double cWidth = MediaQuery.of(context).size.width * 0.6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Container(
                  width: cWidth,
                  child: new Column(children: <Widget>[
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                      ),
                    )
                  ]),
                )
              ]),
              Padding(padding: EdgeInsets.only(bottom: imageSize)),
              Container(
                  height: imageSize,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return this.buildImage(context, members[index]);
                      })),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildItem(BuildContext context) {
    int knessetNum = bill["d:KnessetNum"];
    String status = bill["d:StatusTypeDesc"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 120,
        width: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(bottom: 2.0)),
                      Row(
                        children: <Widget>[
                          Text(
                            'כנסת :',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$knessetNum',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 2.0)),
                      Row(
                        children: <Widget>[
                          Text(
                            'סטטוס :',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            status,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                  child: buildDesc(context)),
            )
          ],
        ),
      ),
    );
  }
}

class BillScreen extends ScreenComponet<ScreenViewModel> {
  final List<ListItem> items = [];
  BillScreen({Key key}) : super(key: key, screenName: Routes.billScreen);
  @override
  ScreenViewModel viewCreator(Store<AppState> store) {
    return ScreenViewModel.fromStore(store);
  }

  load(ScreenViewModel viewModel) {
    final KnessetState knessetState = viewModel.knessetState;
    final List<dynamic> knessetMemberBill = knessetState.knessetMemberBill;
    items.clear();
    Map<int, ListItem> billList = {};
    int billID;
    knessetMemberBill.forEach((bill) => {
          billID = bill["d:BillID"],
          if (billList.containsKey(billID))
            billList[billID].addMember(bill["info"])
          else
            billList[billID] = new ListItem(bill, [bill["info"]])
        });
    billList.entries.forEach((element) {
      items.add(element.value);
    });
  }

  @override
  buildScreen(ScreenViewModel viewModel, BuildContext context,
      BoxConstraints viewportConstraints) {
    load(viewModel);
    return Expanded(
      child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            KnesetMemberItem member = new KnesetMemberItem(item.bill["info"]);
            return new GestureDetector(
                //You need to make my child interactive
                onTap: () => {
                      /*
                      Navigator.pushNamed(context, Routes.memberScreen,
                          arguments: member)*/
                    },
                child: new Card(
                    //I am the clickable child
                    child: item.buildItem(context)));
            //return item.buildItem(context);
          }),
    );
  }
}
