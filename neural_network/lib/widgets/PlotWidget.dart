import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MyPlotWidget extends StatelessWidget {
  List<List<double>> data;
  MyPlotWidget({super.key, required this.data});

  List<SfCartesianChart> buildWidgetList() {
    List<SfCartesianChart> widgetList = [];

    for (var i = 0; i < data.length; i++) {
      widgetList.add(SfCartesianChart());
    }

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: buildWidgetList()));
  }
}
