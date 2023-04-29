import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:neural_network/classes/Layer.dart';

class NeuralNetwork extends ChangeNotifier {
  final List<int> _layerSizes;
  late List<Layer> _layers;
  final double learningRate;
  double epochs = 1e4;

  List<int> get layerSizes => _layerSizes;
  List<Layer> get layers => _layers;

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

    Matrix inputMatrix = Matrix.row(inputs); // (1xI)
    Matrix outputMatrix = Matrix.row(outputs);
    List<double> estimation = forward(inputs);
    Matrix estimationMatrix = Matrix.row(estimation);
    Matrix errorMatrix = estimationMatrix - outputMatrix; //(1xJ)
    List<double> hiddenOutputs = _layers[1].output();
    Matrix hiddenMatrix = Matrix.row(hiddenOutputs); //(1xK)

    // Calculate output of the Lauers without activation function applied
    List<double> hiddenOutputsRaw = _layers[1].summedInputs(inputs);
    List<double> outputsRaw = _layers[2].summedInputs(hiddenOutputs);

    // Calculate derivatives
    List<double> dSigmaList2 = outputsRaw
        .map((e) => _layers[2].derivativeActivationFunction(e))
        .toList();
    Matrix dSigma2 = Matrix.row(dSigmaList2); //(1xJ)
    Matrix dLdB2 = dSigma2.multiply(errorMatrix); //(1xJ)
    Matrix dLdW2 = hiddenMatrix.transpose() * dLdB2; //(KxJ)

    List<double> dSigmaList1 = hiddenOutputsRaw
        .map((e) => _layers[1].derivativeActivationFunction(e))
        .toList();
    Matrix dSigma1 = Matrix.row(dSigmaList1); // (1xK)
    Matrix dLdB1 =
        dSigma1.multiply(dLdB2 * _layers[2].weightMatrix().transpose()); //(1xK)
    Matrix dLdW1 = inputMatrix.transpose() * dLdB1; // (IxK)

    return [dLdW1, dLdB1, dLdW2, dLdB2];
  }

  void updateWeights(List<Matrix> gradients) {
    for (var i = 0; i < gradients.length / 2; i += 2) {
      int tmpLayerNr = (i / 2 + 1).toInt();
      assert(gradients[i].rowCount == _layers[tmpLayerNr].inputSize,
          "ERROR: gradients not compatible with layer size");
      assert(gradients[i].columnCount == _layers[tmpLayerNr].outputSize,
          "ERROR: gradients not compatible with layer size");
      assert(gradients[i + 1].rowCount == 1,
          "ERROR: gradients not compatible with layer size");
      assert(gradients[i + 1].columnCount == _layers[tmpLayerNr].outputSize,
          "ERROR: gradients not compatible with layer size");
    }
    Matrix dLdW1 = gradients[0];
    Matrix dLdB1 = gradients[1];
    Matrix dLdW2 = gradients[2];
    Matrix dLdB2 = gradients[3];

    // Update weights
    _layers[1].weights =
        matrix2List(Matrix.fromList(_layers[1].weights) - dLdW1 * learningRate);
    _layers[1].biases =
        vector2List(Matrix.row(_layers[1].biases) - dLdB1 * learningRate);
    _layers[2].weights =
        matrix2List(Matrix.fromList(_layers[2].weights) - dLdW2 * learningRate);
    _layers[2].biases =
        vector2List(Matrix.row(_layers[2].biases) - dLdB2 * learningRate);
  }

  void train(List<List<double>> inputs, List<List<double>> outputs) {
    for (var j = 0; j < epochs; j++) {
      List<Matrix> totalGradients = [];

      for (var i = 0; i < inputs.length; i++) {
        // int index = Random().nextInt(inputs.length);
        List<Matrix> gradients = backward(inputs[i], outputs[i]);
        int m = gradients.length;

        if (i == 0) {
          for (var i = 0; i < m; i++) {
            totalGradients[i] = gradients[i] * 1 / m;
          }
        } else {
          for (var i = 0; i < m; i++) {
            totalGradients[i] += gradients[i] * 1 / m;
          }
        }
      }
      updateWeights(totalGradients);
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
