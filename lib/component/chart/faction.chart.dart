import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'dart:math' as math;

class FactionChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final List<charts.TickSpec<String>> staticTicks;
  FactionChart(this.seriesList, this.staticTicks, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory FactionChart.fromMember(KnesetMember member) {
    List<charts.TickSpec<String>> staticTicks = [];
    return new FactionChart(
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
          //dateTimeFactory: const charts.LocalDateTimeFactory()
          barGroupingType: charts.BarGroupingType.grouped,
          // Add the legend behavior to the chart to turn on legends.
          // This example shows how to change the position and justification of
          // the legend, in addition to altering the max rows and padding.
          behaviors: [
            new charts.SeriesLegend(
              // Positions for "start" and "end" will be left and right respectively
              // for widgets with a build context that has directionality ltr.
              // For rtl, "start" and "end" will be right and left respectively.
              // Since this example has directionality of ltr, the legend is
              // positioned on the right side of the chart.
              position: charts.BehaviorPosition.end,
              // By default, if the position of the chart is on the left or right of
              // the chart, [horizontalFirst] is set to false. This means that the
              // legend entries will grow as new rows first instead of a new column.
              horizontalFirst: false,
              // This defines the padding around each legend entry.
              cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
              // Set show measures to true to display measures in series legend,
              // when the datum is selected.
              showMeasures: false,
              // Optionally provide a measure formatter to format the measure value.
              // If none is specified the value is formatted as a decimal.
              measureFormatter: (num value) {
                return value == null ? '-' : '${value}k';
              },
            ),
          ],
        ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearValue, String>> _createData(
      KnesetMember member, List<charts.TickSpec<String>> staticTicks) {
    final List items = [];
    final List knessetYears = [];
    Map<String, Map> yearDic = {};
    Map<String, Color> colorDic = {};
    Map<String, List<LinearValue>> total = {};
    Map<String, List<LinearValue>> totalDone = {};
    items.forEach((element) => {
          if (element["factionName"] != null)
            {
              if (!yearDic.containsKey(element["factionName"]))
                {
                  total[element["factionName"]] = [],
                  totalDone[element["factionName"]] = [],
                  yearDic[element["factionName"]] = {},
                  colorDic[element["factionName"]] = Color(
                          (math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                      .withOpacity(1.0)
                },
              yearDic[element["factionName"]][element["lastUpdateDateYear"]] =
                  element
            }
        });
    knessetYears.forEach((fy) => {
          yearDic.forEach((k, v) => {
                if (v.containsKey(fy))
                  {
                    total[k].add(
                        new LinearValue("$fy", v[fy]["total"], colorDic[k])),
                    totalDone[k].add(
                        new LinearValue("$fy", v[fy]["totalDone"], colorDic[k]))
                  }
                else
                  {
                    total[k].add(new LinearValue("$fy", 0, colorDic[k])),
                    totalDone[k].add(new LinearValue("$fy", 0, colorDic[k]))
                  }
              })
        });
    List<charts.Series<LinearValue, String>> list = [];
    yearDic.forEach((k, v) => {
          list.add(new charts.Series<LinearValue, String>(
            id: k,
            colorFn: (LinearValue data, __) =>
                charts.ColorUtil.fromDartColor(data.color),
            domainFn: (LinearValue data, _) => data.year,
            measureFn: (LinearValue data, _) => data.value,
            data: total[k],
          ))
        });

    if (knessetYears.length > 8) {
      int step = (knessetYears.length / 8).round();
      for (int i = 0; i < knessetYears.length; i += step)
        staticTicks.add(charts.TickSpec("${knessetYears[i]}"));
    } else {
      knessetYears.forEach((f) => {staticTicks.add(charts.TickSpec("$f"))});
    }
    return list;
  }
}

/// Sample linear data type.
class LinearValue {
  final String year;
  final int value;
  final Color color;

  LinearValue(this.year, this.value, this.color);
}
