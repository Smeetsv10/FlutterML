import 'package:flutter/material.dart';
import 'package:machine_learning/classes/classes.dart';
import 'package:machine_learning/widgets/neuron_widget.dart';

class LayerWidget extends StatelessWidget {
  final Layer layer;
  const LayerWidget({super.key, required this.layer});

  @override
  Widget build(BuildContext context) {
    List<Widget> buildwidgetList() {
      List<Widget> widgetList = [];
      for (var neuron in layer.neurons) {
        widgetList.add(NeuronWidget(neuron: neuron));
      }
      return widgetList;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: buildwidgetList(),
    );
  }
}
