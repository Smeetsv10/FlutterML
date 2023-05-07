import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
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

  List<Matrix> computeGradients(List<double> inputs, List<double> outputs) {
    assert(inputs.length == layers.first.inputSize);
    assert(outputs.length == layers.last.outputSize);
    List<Matrix> gradients = [];

    List<double> estimation = forward(inputs);
    List<double> error =
        List.generate(outputs.length, (i) => estimation[i] - outputs[i]);

    // Calculate output layer gradients
    List<double> tmpInputs = layers[layers.length - 2].outputs();
    List<double> tmpOutputsRaw = layers.last.forwardLinear(tmpInputs);
    List<double> dSigma = tmpOutputsRaw
        .map((e) => layers.last.derivativeActivationFunction(e))
        .toList();
    Matrix dLdB = Matrix.column(
        List.generate(outputs.length, (i) => dSigma[i] * error[i]));

    Matrix dLdW = Matrix.column(tmpInputs) * dLdB;
    gradients.add(dLdW);
    gradients.add(dLdB);

    return gradients;
  }
}
