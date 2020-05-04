import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'dart:math' as math;

class AttendanceChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final List<charts.TickSpec<String>> staticTicks;
  AttendanceChart(this.seriesList, this.staticTicks, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory AttendanceChart.fromMember(KnesetMember member) {
    List<charts.TickSpec<String>> staticTicks = [];
    return new AttendanceChart(
      _createData(member, staticTicks),
      staticTicks,
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Directionality(
        textDirection: TextDirection.ltr,
        child: new charts.BarChart(
          seriesList,
          animate: animate,
          domainAxis: new charts.OrdinalAxisSpec(
            tickProviderSpec:
                new charts.StaticOrdinalTickProviderSpec(staticTicks),
            renderSpec: charts.GridlineRendererSpec(
              labelRotation: 45,
            ),
          ),
          barGroupingType: charts.BarGroupingType.stacked,
          //defaultRenderer: new charts.BarRendererConfig(
          //    groupingType: charts.BarGroupingType.stacked, strokeWidthPx: 2.0),
        ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearValue, String>> _createData(
      KnesetMember member, List<charts.TickSpec<String>> staticTicks) {
    Map stats = member.knessetAttendance;

    List<charts.Series<LinearValue, String>> all = [];
    List<LinearValue> attendace;
    List knessetYears = [];
    Map years = {};
    Color color;
    stats.entries.forEach((f) => {
          attendace = [],
          color = Color(
                  (0x00FF00 + math.Random().nextDouble() * 0xFF00FF).toInt() <<
                      0)
              .withOpacity(1.0),
          f.value.entries.forEach((mf) => {
                years[mf.key] = true,
                attendace.add(new LinearValue("${mf.key}", mf.value, color))
              }),
          all.add(new charts.Series<LinearValue, String>(
            id: "Attendace",
            seriesCategory: "${f.key}",
            colorFn: (LinearValue data, __) =>
                charts.ColorUtil.fromDartColor(data.color),
            domainFn: (LinearValue data, _) => data.year,
            measureFn: (LinearValue data, _) => data.value,
            data: attendace,
          ))
        });
    years.entries.forEach((mf) => {knessetYears.add(int.parse(mf.key))});
    knessetYears.sort((a, b) => a - b);
    if (knessetYears.length > 8) {
      int step = (knessetYears.length / 8).round();
      for (int i = 0; i < knessetYears.length; i += step)
        staticTicks.add(charts.TickSpec("${knessetYears[i]}"));
    } else {
      knessetYears.forEach((f) => {staticTicks.add(charts.TickSpec("$f"))});
    }
    return all;
  }
}

/// Sample linear data type.
class LinearValue {
  final String year;
  final int value;
  final Color color;

  LinearValue(this.year, this.value, this.color);
}
