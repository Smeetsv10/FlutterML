import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:neural_network/classes/Layer.dart';

class NeuralNetwork with ChangeNotifier {
  final List<int> _layerSizes;
  late List<Layer> _layers;
  final double learningRate;
  bool _isTraining = false;
  double epochs = 1e4;

  List<int> get layerSizes => _layerSizes;
  List<Layer> get layers => _layers;
  bool get isTraining => _isTraining;

  NeuralNetwork(this._layerSizes, {this.learningRate = 1e0}) {
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

  List<Matrix> backward(List<double> inputs, List<double> outputs) {
    assert(inputs.length == _layers.first.inputSize);
    assert(outputs.length == _layers.last.outputSize);
    List<Matrix> gradients = [];

    Matrix inputMatrix = Matrix.row(inputs); // (1xI)
    Matrix outputMatrix = Matrix.row(outputs);
    List<double> estimation = forward(inputs);
    Matrix estimationMatrix = Matrix.row(estimation);
    Matrix errorMatrix = estimationMatrix - outputMatrix; //(1xJ)

    // Calculate gradients output layer
    // -------------------------------------------------------------------------
    Matrix tmpInputMatrix = _layers[_layers.length - 2].outputMatrix();
    List<double> tmpInputs = _layers[_layers.length - 2].output();
    List<double> outputsRaw = _layers.last.summedInputs(tmpInputs);
    Matrix dSigma = Matrix.row(outputsRaw
        .map((e) => _layers.last.derivativeActivationFunction(e))
        .toList());
    Matrix tmpMatrix = dSigma.multiply(errorMatrix);
    gradients.add(tmpInputMatrix.transpose() * tmpMatrix); //(KxJ)
    gradients.add(tmpMatrix); //(1xJ)

    // Loop though layers
    for (int i = _layers.length - 2; i >= 1; i--) {
      tmpInputMatrix = _layers[i - 1].outputMatrix();
      tmpInputs = _layers[i - 1].output();
      outputsRaw = _layers[i].summedInputs(tmpInputs);
      dSigma = Matrix.row(outputsRaw
          .map((e) => _layers[i].derivativeActivationFunction(e))
          .toList());

      tmpMatrix = dSigma
          .multiply(gradients.last * _layers[i + 1].weightMatrix().transpose());

      gradients.add(tmpInputMatrix.transpose() * tmpMatrix);
      gradients.add(tmpMatrix);
    }

    return gradients;
  }

  void updateWeights(List<Matrix> gradients) {
    for (int i = 0; i <= gradients.length / 2; i += 2) {
      int tmpLayerNr = (_layers.length - 1 - i / 2).toInt();
      Matrix dLdW = gradients[i];
      Matrix dLdB = gradients[i + 1];
      // Check gradient sizes
      // -----------------------------------------------------------------------
      assert(dLdW.rowCount == _layers[tmpLayerNr].inputSize,
          "ERROR: gradients not compatible with layer size");
      assert(dLdW.columnCount == _layers[tmpLayerNr].outputSize,
          "ERROR: gradients not compatible with layer size");
      assert(dLdB.rowCount == 1,
          "ERROR: gradients not compatible with layer size");
      assert(dLdB.columnCount == _layers[tmpLayerNr].outputSize,
          "ERROR: gradients not compatible with layer size");

      // Update weights
      _layers[tmpLayerNr].weights = matrix2List(
          Matrix.fromList(_layers[tmpLayerNr].weights) - dLdW * learningRate);
      _layers[tmpLayerNr].biases = vector2List(
          Matrix.row(_layers[tmpLayerNr].biases) - dLdB * learningRate);
    }
  }

  void train(List<List<double>> inputs, List<List<double>> outputs) async {
    _isTraining = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));

    for (var j = 0; j < epochs; j++) {
      List<Matrix> totalGradients = [];
      double error = 0;

      for (var i = 0; i < inputs.length; i++) {
        List<Matrix> gradients = backward(inputs[i], outputs[i]);
        double tmpError = List.generate(outputs[i].length,
                (index) => _layers.last.output()[index] - outputs[i][index])
            .fold(0, (a, b) => a + b);
        if (tmpError > error) {
          error = tmpError;
        }
        if (i == 0) {
          totalGradients = gradients;
        } else {
          for (var i = 0; i < gradients.length; i++) {
            totalGradients[i] += gradients[i];
          }
        }
      }
      for (Matrix totalGradient in totalGradients) {
        totalGradient = totalGradient * (1 / inputs.length);
      }
      updateWeights(totalGradients);

      // if (j % epochs / 1000 == 0 && error > 0.05) {
      //   notifyListeners();
      //   await Future.delayed(Duration(milliseconds: 100));
      // }
    }
    _isTraining = false;
    notifyListeners();
    //await Future.delayed(Duration(milliseconds: 100));
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

  List<List<double>> matrix2List(Matrix matrix) {
    return matrix.toList().map((row) => row.toList()).toList();
  }

  List<double> vector2List(Matrix matrix) {
    assert(matrix.length == 1, 'Input matrix not a row matrix');
    return matrix.getRow(0).toList();
  }
}

    // // Loop through layers
    // for (var i = _layers.length; i >= 1; i--) {
    //   Matrix inputMatrix = _layers[i - 1].outputMatrix();
    //   List<double> layerOutputs = _layers[i].output();
    //   List<double> layerSummedinputs = _layers[i - 1].summedInputs(
    //       inputs); // node values without activation function applied (1xJ)
    //   Matrix dSigma = Matrix.row(layerSummedinputs
    //       .map((e) => _layers[i].derivativeActivationFunction(e))
    //       .toList()); // (1xJ)

    //   // Calculate gradients
    //   Matrix biasGradient = errorMatrix * dSigma; // (1xJ)
    //   Matrix weightGradient = biasGradient.transpose() * inputMatrix; //(IxJ)
    //   if (i < layers.length) {
    //     biasGradient = biasGradient * _layers[i + 1].weightMatrix();
    //   }

    //   // Update weights and biases
    //   Matrix newWeights =
    //       _layers[i].weightMatrix() - weightGradient * learningRate;
    //   _layers[i].weights = matrix2List(newWeights);
    //   Matrix newBiases = _layers[i].biasMatrix() - biasGradient * learningRate;
    //   _layers[i].biases = vector2List(newBiases);
    // }
