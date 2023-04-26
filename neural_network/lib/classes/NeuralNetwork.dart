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

  NeuralNetwork(this._layerSizes, {this.learningRate = 1e5}) {
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
    assert(inputs.length == _layers.first.inputSize,
        'ERROR: specified inputs size not same as inputLayer');

    List<double> outputs = inputs;
    for (Layer layer in _layers) {
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
    Matrix hiddenMatrix = Matrix.column(hiddenOutputs);

    // Calculate output of the Lauers withoud sigmoid applied
    List<double> inputsSummed = _layers[1].summedInputs(inputs);
    List<double> hiddenOutputsSummed = _layers[2].summedInputs(hiddenOutputs);

    // Calculate derivatives
    Matrix dsigmadz = Matrix.column(hiddenOutputsSummed
        .map((e) => _layers[2].derivativeActivationFunction(e))
        .toList());
    Matrix dLdB2 = errorMatrix * dsigmadz;
    Matrix dLdW2 = (dLdB2 * hiddenMatrix.transpose()).transpose();

    List<List<double>> weight2 = _layers[2].weights;
    List<double> dsigmadv = inputsSummed
        .map((e) => _layers[1].derivativeActivationFunction(e))
        .toList();
    for (var i_row = 0; i_row < hiddenOutputs.length; i_row++) {
      for (var i_col = 0; i_col < outputs.length; i_col++) {
        weight2[i_row][i_col] *= dsigmadv[i_row];
      }
    }
    Matrix weightMat2 = Matrix.fromList(weight2).transpose();
    Matrix dLdW1 = inputMatrix * dLdB2 * weightMat2;
    Matrix dLdB1 = (dLdB2 * weightMat2).transpose();

    // Update weights
    _layers[1].weights =
        (Matrix.fromList(_layers[1].weights) - dLdW1 * learningRate)
            .toList()
            .map((row) => row.toList())
            .toList();
    _layers[1].biases =
        (Matrix.column(_layers[1].biases) - dLdB1 * learningRate)
            .expand((element) => element)
            .toList();
    _layers[2].weights =
        (Matrix.fromList(_layers[2].weights) - dLdW2 * learningRate)
            .toList()
            .map((row) => row.toList())
            .toList();
    _layers[2].biases =
        (Matrix.column(_layers[2].biases) - dLdB2 * learningRate)
            .expand((element) => element)
            .toList();
    return errorMatrix.sum();
  }

  List<double> train(List<List<double>> inputs, List<List<double>> outputs) {
    List<double> errorList = [];
    for (var j = 0; j < epochs; j++) {
      for (var i = 0; i < inputs.length; i++) {
        // int index = Random().nextInt(inputs.length);
        double error = backward(inputs[i], outputs[i]);
        errorList.add(error);
      }
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
