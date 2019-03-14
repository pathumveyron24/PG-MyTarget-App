import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:charts_flutter/flutter.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<charts.Series> seriesList = null;
  final bool animate = true;

  @override
  void initState() {
    super.initState();
    Firestore.instance.collection('targets').snapshots().listen((data) {
      int amount = 0;
      int complete = 0;
      data.documents.forEach((doc) {
        amount += doc["amount"];
        complete += doc["complete"];
      });
      setState(() {
        seriesList = _createSampleData(amount, complete);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: (seriesList != null)
            ? new charts.PieChart(seriesList,
                animate: animate,
                // Configure the width of the pie slices to 60px. The remaining space in
                // the chart will be left as a hole in the center.
                defaultRenderer: new charts.ArcRendererConfig(
                    arcWidth: 100,
                    arcRendererDecorators: [new charts.ArcLabelDecorator()]))
            : new Text("Loading..."));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<Data, int>> _createSampleData(amount, complete) {
    final data = [
      new Data(0, complete, "Completed"),
      new Data(1, amount - complete, "Remaining"),
    ];

    return [
      new charts.Series<Data, int>(
        id: 'Target Archived',
        domainFn: (Data target, _) => target.key,
        measureFn: (Data target, _) => target.value,
        labelAccessorFn: (Data target, _) =>
            target.name + " :\n " + target.value.toString(),
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class Data {
  final int key;
  final int value;
  final String name;

  Data(this.key, this.value, this.name);
}
