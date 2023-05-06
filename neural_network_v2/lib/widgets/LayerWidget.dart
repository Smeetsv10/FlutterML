import 'package:flutter/material.dart';
import 'package:neural_network_v2/classes/Layer.dart';
import 'package:neural_network_v2/widgets/NeuronWidget.dart';

class LayerWidget extends StatelessWidget {
  final Layer layer;

  LayerWidget({Key? key, required this.layer});

  @override
  Widget build(BuildContext context) {
    List<NeuronWidget> neuronWidgetList = List.generate(
        layer.outputSize, (i) => NeuronWidget(neuron: layer.neurons[i]));

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: neuronWidgetList,
      ),
    );
  }
}
