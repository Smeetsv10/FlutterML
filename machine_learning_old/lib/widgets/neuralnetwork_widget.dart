import 'package:flutter/material.dart';
import 'package:machine_learning/classes/classes.dart';
import 'package:machine_learning/widgets/layer_widget.dart';

class NeuralNetworkWidget extends StatelessWidget {
  final NeuralNetwork neuralNetwork;
  final List<double>? inputs;
  const NeuralNetworkWidget(
      {super.key, required this.neuralNetwork, this.inputs});

  @override
  Widget build(BuildContext context) {
    List<Widget> buildwidgetList() {
      List<Widget> widgetList = [];

      if (inputs?.isNotEmpty == true) {
        widgetList.add(Expanded(
          child: LayerWidget(
            layer: Layer(
              List.generate(
                inputs!.length,
                (index) => Neuron(value: inputs![index]),
              ),
            ),
          ),
        ));
      }

      widgetList.add(Expanded(
          child: Container(
        child: const Icon(Icons.arrow_right_alt_rounded),
      )));

      for (var layer in neuralNetwork.layers) {
        widgetList.add(Expanded(child: LayerWidget(layer: layer)));
        widgetList.add(Expanded(
            child: Container(
          child: const Icon(Icons.arrow_right_alt_rounded),
        )));
      }

      widgetList.removeLast();
      return widgetList;
    }

    return Stack(
      children: [
        Row(children: buildwidgetList()),
      ],
    );
  }
}
