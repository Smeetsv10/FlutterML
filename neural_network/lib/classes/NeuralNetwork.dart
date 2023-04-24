import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:neural_network/classes/Layer.dart';

class NeuralNetwork extends ChangeNotifier {
  final List<int> _layerSizes;
  late List<Layer> _layers;
  final double learningRate;
  double epochs = 1e5;

  List<int> get layerSizes => _layerSizes;
  List<Layer> get layers => _layers;

  NeuralNetwork(this._layerSizes, {this.learningRate = 1e-2}) {
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

  double backward(List<double> inputs, List<double> outputs) {
    assert(inputs.length == _layers.first.inputSize);
    assert(outputs.length == _layers.last.outputSize);

    Matrix inputMatrix = Matrix.column(inputs);
    Matrix outputMatrix = Matrix.column(outputs);
    List<double> estimation = forward(inputs);
    Matrix estimationMatrix = Matrix.column(estimation);
    Matrix errorMatrix = estimationMatrix - outputMatrix;
    List<double> hiddenOutputs = _layers[1].output();
    Matrix hiddenMatrix = _layers[1].outputMatrix();

    // Calculate output of the Lauers withoud sigmoid applied
    List<double> inputsSummed = _layers[1].summedInputs(inputs);
    List<double> hiddenOutputsSummed = _layers[2].summedInputs(hiddenOutputs);

    // Calculate derivatives
    // Matrix dLdW2 = (errorMatrix *
    //         _layers[2].derivativeActivationFunction(inputsSummed) *
    //         hiddenMatrix.transpose())
    //     .transpose();
    // Matrix dLdB2 =
    //     errorMatrix * _layers[2].derivativeActivationFunction(inputsSummed);
    // Matrix dLdW1 = (Matrix.fromList(_layers[2].weights) *
    //         dLdB2 *
    //         _layers[1].derivativeActivationFunction(hiddenOutputsSummed) *
    //         inputMatrix.transpose())
    //     .transpose();
    // Matrix dLdB1 = Matrix.fromList(_layers[2].weights) *
    //     dLdB2 *
    //     _layers[1].derivativeActivationFunction(hiddenOutputsSummed);
    Matrix dLdW2 = (errorMatrix *
            Matrix.column(inputsSummed
                .map((e) => _layers[2].derivativeActivationFunction(e))
                .toList()) *
            hiddenMatrix.transpose())
        .transpose();
    Matrix dLdB2 = errorMatrix *
        Matrix.column(inputsSummed
            .map((e) => _layers[2].derivativeActivationFunction(e))
            .toList());
    Matrix dLdW1 = (Matrix.fromList(_layers[2].weights) *
            dLdB2 *
            Matrix.column(hiddenOutputsSummed
                .map((e) => _layers[1].derivativeActivationFunction(e))
                .toList()) *
            inputMatrix.transpose())
        .transpose();
    Matrix dLdB1 = Matrix.fromList(_layers[2].weights) *
        dLdB2 *
        Matrix.column(hiddenOutputsSummed
            .map((e) => _layers[1].derivativeActivationFunction(e))
            .toList());

    // print('dLdW1: $dLdW1');
    // print('dLdB1: $dLdB1');
    // print('dLdW2: $dLdW2');
    // print('dLdB2: $dLdB2');
    // print('');

    // Update weights
    _layers[1].weights =
        (Matrix.fromList(_layers[1].weights) - dLdW1 * learningRate)
            .toList()
            .map((row) => row.toList())
            .toList();
    layers[1].biases = (Matrix.column(_layers[1].biases) - dLdB1 * learningRate)
        .expand((element) => element)
        .toList();
    _layers[2].weights =
        (Matrix.fromList(_layers[2].weights) - dLdW2 * learningRate)
            .toList()
            .map((row) => row.toList())
            .toList();
    layers[2].biases = (Matrix.column(_layers[2].biases) - dLdB2 * learningRate)
        .expand((element) => element)
        .toList();

    return subtractLists(estimation, outputs).fold(0, (a, b) => a + b);
  }

  List<double> train(List<List<double>> inputs, List<List<double>> outputs) {
    List<double> errorList = [];
    for (var j = 0; j < epochs; j++) {
      int index = Random().nextInt(inputs.length);
      double error = backward(inputs[index], outputs[index]);
      errorList.add(error);
    }
    return errorList;
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
