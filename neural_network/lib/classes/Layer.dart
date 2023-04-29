import 'dart:math';
import 'package:ml_linalg/linalg.dart';
import 'package:neural_network/classes/ActivationFuntion.dart';
import 'package:neural_network/classes/NeuralNetwork.dart';
import 'package:neural_network/classes/Neuron.dart';

class Layer {
  final NeuralNetwork neuralNetwork;
  final int layerNr;
  final int inputSize; // I
  final int outputSize; // J
  final double Function(double) activationFunction = sigmoid;
  final double Function(double) derivativeActivationFunction =
      sigmoidDerivative;
  bool applyActivationFuction = true;
  late List<List<double>> weights; // IxJ
  late List<double> biases; // 1xJ
  late List<Neuron> neurons;
  late bool isInputLayer;

  Layer(this.neuralNetwork, this.inputSize, this.outputSize, this.layerNr) {
    weights = initializeWeights();
    biases = initializeBiases();
    neurons = initializeNeurons(outputSize);
    isInputLayer = layerNr == 0;
  }

  // Initialize variables
  // ---------------------------------------------------------------------------
  List<List<double>> initializeWeights() {
    //return List.generate(inputSize, (i) => List.generate(outputSize, (j) => 0));
    return List.generate(inputSize,
        (i) => List.generate(outputSize, (j) => Random().nextDouble() + 0.5));
  }

  List<double> initializeBiases() {
    return List.generate(outputSize, (j) => 0);
    return List.generate(outputSize, (j) => Random().nextDouble() - 0.5);
  }

  List<Neuron> initializeNeurons(int inputSize) {
    return List.generate(
        inputSize, (int i) => Neuron(neuralNetwork, 0, [layerNr, i]));
  }

  // Forward Propagation
  // ---------------------------------------------------------------------------
  List<double> forward(List<double> inputs) {
    assert(inputs.length == inputSize,
        'ERROR: Specified inputs do not correspond with inputSize');

    if (isInputLayer) {
      for (int j = 0; j < outputSize; j++) {
        neurons[j].setValue(inputs[j]);
      }
      return inputs;
    }

    Matrix weightMatrix = Matrix.fromList(weights);
    Matrix biasMatrix = Matrix.row(biases);
    Matrix inputMatrix = Matrix.row(inputs);

    Matrix outputMatrix = inputMatrix * weightMatrix + biasMatrix;
    List<double> outputs = outputMatrix.getRow(0).toList();
    if (applyActivationFuction) {
      for (int j = 0; j < outputSize; j++) {
        outputs[j] = activationFunction(outputs[j]);
        neurons[j].setValue(outputs[j]);
      }
    }
    return outputs;
  }

  Matrix weightMatrix() {
    return Matrix.fromList(weights);
  }

  Matrix biasMatrix() {
    return Matrix.row(biases);
  }

  List<double> output() {
    List<double> outputs = [];
    for (var neuron in neurons) {
      outputs.add(neuron.value);
    }
    return outputs;
  }

  Matrix outputMatrix() {
    return Matrix.row(output());
  }

  List<double> summedInputs(List<double> inputs) {
    // Forward result without activation fuction applied
    applyActivationFuction = false;
    List<double> outputs = forward(inputs);
    applyActivationFuction = true;
    return outputs;
  }
}
