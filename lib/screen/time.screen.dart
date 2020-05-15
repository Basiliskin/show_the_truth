import 'package:flutter/material.dart';
import 'package:knesset_odata/component/chart/attendance.time.chart.dart';
import 'package:knesset_odata/component/screen.componet.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/navigation.model.dart';
import 'package:knesset_odata/model/redux/state/knesset.state.dart';
import 'package:knesset_odata/model/viewmodel/screen.viewmodel.dart';
import 'package:redux/redux.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';

class TimeScreen extends ScreenComponet<ScreenViewModel> {
  TimeScreen({Key key}) : super(key: key, screenName: Routes.timeScreen);
  @override
  ScreenViewModel viewCreator(Store<AppState> store) {
    return ScreenViewModel.fromStore(store);
  }

  @override
  buildScreen(ScreenViewModel viewModel, BuildContext context,
      BoxConstraints viewportConstraints) {
    final KnessetState knessetState = viewModel.knessetState;
    final List<KnessetAttendanceData> attendance =
        knessetState.knessetAttendance;
    List<Widget> children = <Widget>[
      Text("סה''כ נוכחות"),
      Expanded(
          child: Container(
              color: Theme.of(context).highlightColor,
              child: AttendanceTimeChart.fromData(
                  attendance, "knessetNum", "total"))),
      Text("ח''כים"),
      Expanded(
          child: Container(
              color: Theme.of(context).highlightColor,
              child: AttendanceTimeChart.fromData(
                  attendance, "knessetNum", "member"))),
      Text("יחס"),
      Expanded(
          child: Container(
              color: Theme.of(context).highlightColor,
              child: AttendanceTimeChart.fromData(
                  attendance, "knessetNum", "ratio"))),
    ];
    //
    return Expanded(
      child: SizedBox(
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          )),
    );
  }
}
