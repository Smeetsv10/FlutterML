import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:neural_network/classes/ActivationFuntion.dart';
import 'package:neural_network/classes/Layer.dart';
import 'package:neural_network/classes/Neuron.dart';
import 'package:neural_network/main.dart';

class NeuralNetwork extends ChangeNotifier {
  final List<int> _layerSizes;
  late List<Layer> _layers;
  final double learningRate;
  double epochs = 1e4;

  List<int> get layerSizes => _layerSizes;
  List<Layer> get layers => _layers;

  NeuralNetwork(this._layerSizes, {this.learningRate = 1e-3}) {
    buildLayers();
  }

  void buildLayers() {
    Layer iputLayer = Layer(this, _layerSizes[0], _layerSizes[0], 0);
    _layers = [iputLayer];

    for (var i = 1; i < _layerSizes.length; i++) {
      _layers.add(Layer(this, _layerSizes[i - 1], _layerSizes[i], i));
    }
  }

  List<double> forward(List<double> inputs) {
    assert(inputs.length == layers.first.inputSize,
        'ERROR: specified inputs size not same as inputLayer');

    List<double> outputs = inputs;
    for (Layer layer in layers) {
      outputs = layer.forward(outputs);
    }
    notifyListeners();
    return outputs;
  }

  void backward(List<double> inputs, List<double> outputs) {
    assert(inputs.length == _layers.first.inputSize);
    assert(outputs.length == _layers.last.outputSize);

    List<double> estimation = forward(inputs);
    List<double> a1 = List.generate(
        _layers[1].outputSize, (index) => _layers[1].neurons[index].value);
    List<double> a2 = List.generate(
        _layers[2].outputSize, (index) => _layers[2].neurons[index].value);

    List<double> dZ2 = subtractLists(a2, outputs);
    List<double> db2 = List.filled(_layerSizes[2], 0);
    List<List<double>> dW2 =
        List.generate(a1.length, (index) => List.filled(a2.length, 0));

    for (var j = 0; j < a2.length; j++) {
      for (var i = 0; i < a1.length; i++) {
        dW2[i][j] = (1 / inputs.length) * dZ2[j] * a1[i] * (1 - a1[i]);
        db2[j] += dW2[i][j];
      }
    }
    List<double> dZ1 = List.generate(a1.length, (index) => 0);
    for (var i = 0; i < inputs.length; i++) {
      for (var j = 0; j < a1.length; j++) {
        dZ1[i] =
            _layers[1].weights[i][j] * dZ1[j] * inputs[i] * (1 - inputs[i]);
      }
    }
    List<double> db1 = List.filled(_layerSizes[1], 0);
    List<List<double>> dW1 = List.generate(
        _layerSizes[0], (index) => List.filled(_layerSizes[1], 0));

    for (var j = 0; j < a1.length; j++) {
      for (var i = 0; i < inputs.length; i++) {
        dW1[i][j] = (1 / inputs.length) * dZ1[j] * inputs[i];
        db1[j] += dW1[i][j];
      }
    }

    Matrix dWeightMatrix1 = Matrix.fromList(dW1);
    _layers[1].weights =
        (Matrix.fromList(_layers[1].weights) - dWeightMatrix1 * learningRate)
            .toList()
            .map((row) => row.toList())
            .toList();
    Matrix dWeightMatrix2 = Matrix.fromList(dW2);
    _layers[2].weights =
        (Matrix.fromList(_layers[2].weights) - dWeightMatrix2 * learningRate)
            .toList()
            .map((row) => row.toList())
            .toList();
    Matrix dBiasMatrix1 = Matrix.column(db1);
    _layers[1].biases =
        (Matrix.column(_layers[1].biases) - dBiasMatrix1 * learningRate)
            .expand((row) => row)
            .toList();
    Matrix dBiasMatrix2 = Matrix.column(db2);
    _layers[2].biases =
        (Matrix.column(_layers[2].biases) - dBiasMatrix2 * learningRate)
            .expand((row) => row)
            .toList();
  }

  void train(List<List<double>> inputs, List<List<double>> outputs) {
    for (var j = 0; j < epochs; j++) {
      int index = Random().nextInt(inputs.length);
      backward(inputs[index], outputs[index]);
    }
  }

  List<double> subtractLists(List<double> list1, List<double> list2) {
    assert(list1.length == list2.length,
        'ERROR: Trying to subtract lists with different lengths');
    List<double> newList = [];
    for (var i = 0; i < list1.length; i++) {
      newList.add(list1[i] - list2[i]);
    }
    return newList;
  }
}
