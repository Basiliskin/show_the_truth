import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:knesset_odata/model/kneset.model.dart';

class KnessetChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  KnessetChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory KnessetChart.fromMember(KnesetMember member) {
    return new KnessetChart(
      _createData(member),
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
          barGroupingType: charts.BarGroupingType.groupedStacked,
        ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearValue, String>> _createData(
      KnesetMember member) {
    final Map stats = member.stats;
    final List<LinearValue> total = [];
    final List<LinearValue> totalDone = [];
    stats.entries.forEach((f) => {
          total.add(new LinearValue("${f.key}", f.value["total"])),
          totalDone.add(new LinearValue("${f.key}", f.value["done"]))
        });

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
