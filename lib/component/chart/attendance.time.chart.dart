import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:knesset_odata/model/kneset.model.dart';

class AttendanceTimeChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final List<charts.TickSpec<String>> staticTicks;
  AttendanceTimeChart(this.seriesList, this.staticTicks, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory AttendanceTimeChart.fromData(
      List<KnessetAttendanceData> data, String xattr, String yattr) {
    List<charts.TickSpec<String>> staticTicks = [];
    return new AttendanceTimeChart(
      _createData(data, xattr, yattr, staticTicks),
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
          barGroupingType: charts.BarGroupingType.groupedStacked,
        ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearValue, String>> _createData(
      List<KnessetAttendanceData> data,
      String xattr,
      String yattr,
      List<charts.TickSpec<String>> staticTicks) {
    final List<LinearValue> total = [];
    data.asMap().forEach((index, value) => total.add(new LinearValue(
        "${value.data[xattr]}",
        1.0 * value.data[yattr],
        index == 0
            ? Colors.blueAccent
            : (data[index - 1].data[yattr] > value.data[yattr]
                ? Colors.redAccent
                : Colors.blueAccent))));
    if (data.length > 8) {
      int step = (data.length / 8).round();
      for (int i = 0; i < data.length; i += step)
        staticTicks.add(charts.TickSpec("${data[i].data[xattr]}"));
    } else {
      data.forEach(
          (f) => {staticTicks.add(charts.TickSpec("${f.data[xattr]}"))});
    }
    return [
      new charts.Series<LinearValue, String>(
        id: 'total',
        seriesCategory: 'A',
        colorFn: (LinearValue data, __) =>
            charts.ColorUtil.fromDartColor(data.color),
        domainFn: (LinearValue data, _) => data.year,
        measureFn: (LinearValue data, _) => data.value,
        data: total,
      )
    ];
  }
}

/// Sample linear data type.
class LinearValue {
  final String year;
  final double value;
  final Color color;

  LinearValue(this.year, this.value, this.color);
}
