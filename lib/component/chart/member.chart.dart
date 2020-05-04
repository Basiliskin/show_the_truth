import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:knesset_odata/model/kneset.model.dart';

class MemberChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  MemberChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory MemberChart.fromMember(KnesetMember member) {
    return new MemberChart(
      _createData(member),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Directionality(
        textDirection: TextDirection.ltr,
        child: new charts.TimeSeriesChart(
          seriesList,
          animate: animate,
          primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                      fontSize: 10, color: charts.MaterialPalette.white),
                  lineStyle: charts.LineStyleSpec(
                      thickness: 1,
                      color: charts.MaterialPalette.gray.shadeDefault))),
          domainAxis: new charts.DateTimeAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
                axisLineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette
                      .white, // this also doesn't change the Y axis labels
                ),
                labelStyle: new charts.TextStyleSpec(
                  fontSize: 10,
                  color: charts.MaterialPalette.gray.shade600,
                ),
                lineStyle: charts.LineStyleSpec(
                  thickness: 1,
                  color: charts.MaterialPalette.gray.shade600,
                )),
            tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
              day: new charts.TimeFormatterSpec(
                format: 'dd',
                transitionFormat: 'yyyy',
              ),
            ),
          ),
          defaultRenderer: new charts.LineRendererConfig(),
          //dateTimeFactory: const charts.LocalDateTimeFactory()
        ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearValue, DateTime>> _createData(
      KnesetMember member) {
    final List items = [];
    final List<LinearValue> total = [];
    final List<LinearValue> totalDone = [];
    final List factionYears = [];
    Map<int, Map> yearDic = {};
    items.forEach(
        (element) => {yearDic[element["lastUpdateDateYear"]] = element});

    factionYears.forEach((fy) => {
          if (yearDic.containsKey(fy))
            {
              total.add(new LinearValue(
                  new DateTime.utc(fy, 1, 1), yearDic[fy]["total"])),
              totalDone.add(new LinearValue(
                  new DateTime.utc(fy, 1, 1), yearDic[fy]["totalDone"]))
            }
          else
            {
              total.add(new LinearValue(new DateTime.utc(fy, 1, 1), 0)),
              totalDone.add(new LinearValue(new DateTime.utc(fy, 1, 1), 0))
            }
        });

    return [
      new charts.Series<LinearValue, DateTime>(
        id: 'total',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearValue data, _) => data.year,
        measureFn: (LinearValue data, _) => data.value,
        data: total,
      ),
      new charts.Series<LinearValue, DateTime>(
        id: 'totalDone',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (LinearValue data, _) => data.year,
        measureFn: (LinearValue data, _) => data.value,
        data: totalDone,
      )
    ];
  }
}

/// Sample linear data type.
class LinearValue {
  final DateTime year;
  final int value;

  LinearValue(this.year, this.value);
}
