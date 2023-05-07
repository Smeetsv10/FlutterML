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

  List<Matrix> computeGradients(List<double> inputs, List<double> outputs) {
    '''gradients is a list of matrix, containing dLdW, dLdB of each layer,
       going from the last to the first''';

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

    for (int i = layers.length - 2; i >= 1; i--) {
      tmpInputs = layers[i - 1].outputs();
      tmpOutputsRaw = layers[i].forwardLinear(tmpInputs);
      dSigma = tmpOutputsRaw
          .map((e) => layers[i].derivativeActivationFunction(e))
          .toList();

      dLdB = Matrix.row(dSigma)
          .multiply(gradients.last * layers[i + 1].weightMatrix.transpose());

      Matrix tmpInputMatrix = layers[i - 1].outputMatrix();
      gradients.add(tmpInputMatrix * dLdB);
      gradients.add(dLdB);
    }

    return gradients;
  }

  void updateWeights(List<Matrix> gradients) {
    for (int i = 0; i <= gradients.length / 2; i += 2) {
      int tmpLayerNr = (layers.length - 1 - i / 2).toInt();
      Matrix dLdW = gradients[i];
      Matrix dLdB = gradients[i + 1];
      // Check gradient sizes
      // -----------------------------------------------------------------------
      assert(dLdW.rowCount == layers[tmpLayerNr].inputSize,
          "ERROR: weights gradient rows not compatible with layer size");
      assert(dLdW.columnCount == layers[tmpLayerNr].outputSize,
          "ERROR: weights gradient columns not compatible with layer size");
      assert(dLdB.rowCount == 1,
          "ERROR: biases gradient rows not compatible with layer size");
      assert(dLdB.columnCount == layers[tmpLayerNr].outputSize,
          "ERROR: biases gradient columns not compatible with layer size");

      // Update weights
      layers[tmpLayerNr].weightMatrix =
          layers[tmpLayerNr].weightMatrix - dLdW * learningRate;
      layers[tmpLayerNr].biasMatrix =
          layers[tmpLayerNr].biasMatrix - dLdB * learningRate;

      layers[tmpLayerNr].weights = layers[tmpLayerNr]
          .weightMatrix
          .toList()
          .map((row) => row.toList())
          .toList();
      layers[tmpLayerNr].biases =
          layers[tmpLayerNr].biasMatrix.getRow(0).toList();
    }
  }

  void train(List<List<double>> inputs, List<List<double>> outputs) async {
    isTraining = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));

    for (var j = 0; j < epochs; j++) {
      List<Matrix> totalGradients = [];
      double error = 0;

      for (var i = 0; i < inputs.length; i++) {
        List<Matrix> gradients = computeGradients(inputs[i], outputs[i]);
        double tmpError = List.generate(outputs[i].length,
                (index) => layers.last.outputs()[index] - outputs[i][index])
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
    isTraining = false;
    notifyListeners();
    //await Future.delayed(Duration(milliseconds: 100));
  }
}
