import 'package:flutter/material.dart';
import 'package:neural_network_v2/classes/Layer.dart';
import 'package:neural_network_v2/classes/Neuron.dart';

class NeuralNetwork extends ChangeNotifier {
  final List<int> layerSizes; // list of layer sizes
  final List<Layer> layers = [];
  int epochs = 10000;
  double learningRate = 1e-1;
  bool isTraining = false;

  NeuralNetwork(this.layerSizes) {
    buildLayers();
  }

  void buildLayers() {
    layers.insert(0, Layer(this, layerSizes[0], layerSizes[0], 0));
    for (var i = 0; i < layerSizes.length - 1; i++) {
      layers.add(Layer(this, layerSizes[i], layerSizes[i + 1], i + 1));
    }
  }

  List<double> forward(List<double> inputs) {
    layers.first.assignNeuronValues(inputs);
    List<double> tmpOutputs = inputs;

    for (var layer in layers.sublist(1)) {
      tmpOutputs = layer.forward(tmpOutputs);
    }
    notifyListeners();
    return tmpOutputs;
  }

  void backward() {}
}
