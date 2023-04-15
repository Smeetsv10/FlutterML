import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neural_network/classes/NeuralNetwork.dart';
import 'package:neural_network/widgets/LayerWidget.dart';
import 'package:provider/provider.dart';

class NeuralNetworkWidget extends StatelessWidget {
  const NeuralNetworkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    NeuralNetwork neuralNetwork =
        Provider.of<NeuralNetwork>(context, listen: true);

    List<LayerWidget> buildwidgetList() {
      List<LayerWidget> widgetList = [];
      for (var i = 0; i < neuralNetwork.layers.length; i++) {
        widgetList.add(LayerWidget(layer: neuralNetwork.layers[i], layerNr: i));
      }
      return widgetList;
    }

    List<LayerWidget> widgetList = buildwidgetList();

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Row(
        children: widgetList,
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        List<double> input = [Random().nextDouble(), Random().nextDouble()];
        // Calculate new node values
        neuralNetwork.forward(input);
        neuralNetwork.train([
          [0, 0],
          [1, 0],
          [0, 1],
          [1, 1]
        ], [
          [0],
          [1],
          [1],
          [0]
        ]);
      }),
    );
  }
}
