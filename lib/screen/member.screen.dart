import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:knesset_odata/component/chart/attendance.component.dart';
import 'package:knesset_odata/component/chart/knesset.chart.dart';
import 'package:knesset_odata/component/screen.componet.dart';
import 'package:knesset_odata/component/stars.component.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/list.model.dart';
import 'package:knesset_odata/model/navigation.model.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/viewmodel/screen.viewmodel.dart';

class MemberScreen extends ScreenComponet<ScreenViewModel> {
  MemberScreen({Key key}) : super(key: key, screenName: Routes.memberScreen);
  @override
  ScreenViewModel viewCreator(Store<AppState> store) {
    return ScreenViewModel.fromStore(store);
  }

  Widget buildImage(KnesetMember member) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        print(member.imgPath);
      },
      child: Container(
          width: 72,
          height: 72,
          padding: EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 72,
              minHeight: 72,
              maxWidth: 72,
              maxHeight: 72,
            ),
            child: member.imgPath != ""
                ? Image.network(member.imgPath, fit: BoxFit.cover)
                : next(1, 5) % 2 == 1
                    ? Image.asset("assets/image/avatarB.png")
                    : Image.asset("assets/image/avatarA.png"),
          )));
  @override
  buildScreen(ScreenViewModel viewModel, BuildContext context,
      BoxConstraints viewportConstraints) {
    final KnesetMemberItem arguments =
        ModalRoute.of(context).settings.arguments;
    final KnesetMember member = arguments.member;
    int totalDone = 0;
    member.stats.entries.forEach((f) => {totalDone += f.value["done"]});

    List<Widget> children = <Widget>[
      Text("כנסת"),
      Expanded(
          child: Container(
              color: Theme.of(context).highlightColor,
              child: KnessetChart.fromMember(member))),
    ];
    //Map stats = member.knessetAttendance;
    //if (stats.entries.length > 0)
    {
      children.add(Text("נוכחות בישיבות"));
      children.add(Expanded(
          child: Container(
              color: Theme.of(context).highlightColor,
              child: AttendanceChart.fromMember(member))));
    }
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        SizedBox(
          height: 120,
          /*1*/
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  buildImage(member),
                  new StarRating(
                    rating: member.stars,
                    //onRatingChanged: (rating) => setState(() => this.rating = rating),
                  ),
                ],
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*2*/
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      member.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    member.cityName,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    member.birthCountry,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
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
                        '${member.knessetNums.length}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black54,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 2.0, right: 2.0)),
                      Text(
                        ', תפקידים/מפלגות :',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${member.positionCount}',
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
                        'הצעות :',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${member.total}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black54,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 2.0, right: 2.0)),
                      Text(
                        ', אושרו :',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$totalDone',
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
              ),
            ],
          ),
        ),
        SizedBox(
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ))
      ]),
    );

    return Expanded(
      child: titleSection,
    );
  }
}
