import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:knesset_odata/model/kneset.model.dart';

class SuggestionChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final List<charts.TickSpec<String>> staticTicks;
  SuggestionChart(this.seriesList, this.staticTicks, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory SuggestionChart.fromMember(KnesetMember member) {
    List<charts.TickSpec<String>> staticTicks = [];
    return new SuggestionChart(
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
          barGroupingType: charts.BarGroupingType.groupedStacked,
        ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearValue, String>> _createData(
      KnesetMember member, List<charts.TickSpec<String>> staticTicks) {
    final List items = [];
    final List<LinearValue> total = [];
    final List<LinearValue> totalDone = [];

    final List knessetYears = [];
    Map<int, Map> yearDic = {};
    items.forEach(
        (element) => {yearDic[element["lastUpdateDateYear"]] = element});

    knessetYears.forEach((fy) => {
          if (yearDic.containsKey(fy))
            {
              total.add(new LinearValue("$fy", yearDic[fy]["total"])),
              totalDone.add(new LinearValue("$fy", yearDic[fy]["totalDone"]))
            }
          else
            {
              total.add(new LinearValue("$fy", 0)),
              totalDone.add(new LinearValue("$fy", 0))
            }
        });
    if (knessetYears.length > 8) {
      int step = (knessetYears.length / 8).round();
      for (int i = 0; i < knessetYears.length; i += step)
        staticTicks.add(charts.TickSpec("${knessetYears[i]}"));
    } else {
      knessetYears.forEach((f) => {staticTicks.add(charts.TickSpec("$f"))});
    }
    return [
      new charts.Series<LinearValue, String>(
        id: 'total',
        seriesCategory: 'A',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearValue data, _) => data.year,
        measureFn: (LinearValue data, _) => data.value,
        data: total,
      ),
      new charts.Series<LinearValue, String>(
        id: 'totalDone',
        seriesCategory: 'B',
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
  final String year;
  final int value;

  LinearValue(this.year, this.value);
}
