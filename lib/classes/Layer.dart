import 'dart:math';

import 'package:ml_linalg/linalg.dart';
import 'package:neural_network_v2/classes/Activationfunction.dart';
import 'package:neural_network_v2/classes/NeuralNetwork.dart';
import 'package:neural_network_v2/classes/Neuron.dart';

class Layer {
  NeuralNetwork neuralNetwork;
  int inputSize;
  int outputSize;
  int layerNr;
  List<Neuron> neurons = [];
  double Function(double) activationFunction = sigmoid;
  double Function(double) derivativeActivationFunction = sigmoidDerivative;

  late List<List<double>> weights;
  late List<double> biases;
  late Matrix weightMatrix; // IxJ
  late Matrix biasMatrix; // 1xJ

  Layer(this.neuralNetwork, this.inputSize, this.outputSize, this.layerNr) {
    buildNeurons();
    initializeWeights();
    initializeBiases();
  }

  // Initialize layers
  // ---------------------------------------------------------------------------
  void buildNeurons() {
    for (var i = 0; i < outputSize; i++) {
      neurons.add(Neuron(layer: this, position: [layerNr, i]));
    }
  }

  void initializeWeights() {
    weights = List.generate(
      inputSize,
      (index) => List.filled(outputSize, Random().nextDouble()),
    );

    weightMatrix = Matrix.fromList(weights);
  }

  void initializeBiases() {
    biases = List.filled(outputSize, 0);
    biasMatrix = Matrix.row(biases);
  }

  // Forward Propagation
  // ---------------------------------------------------------------------------
  List<double> forwardLinear(List<double> inputs) {
    Matrix inputMatrix = Matrix.column(inputs); // (Ix1)
    Matrix outputMatrix =
        weightMatrix.transpose() * inputMatrix + biasMatrix.transpose(); //(Jx1)
    assert(
      outputMatrix.columnCount == 1,
      'ERROR: Multiple columns for output matrix',
    );
    List<double> outputs = outputMatrix.getColumn(0).toList();
    return outputs;
  }

  List<double> forward(List<double> inputs) {
    List<double> tmpOutputs = forwardLinear(inputs);
    List<double> outputs =
        tmpOutputs.map((value) => activationFunction(value)).toList();
    assignNeuronValues(outputs);
    return outputs;
  }
  // Backward Propagation
  // ---------------------------------------------------------------------------

  // Helper Functions
  // ---------------------------------------------------------------------------
  void assignNeuronValues(List<double> values) {
    assert(values.length == neurons.length,
        'ERROR: Neurons and values sizes not compatible');
    for (var i = 0; i < neurons.length; i++) {
      neurons[i].value = values[i];
    }
  }

  List<double> outputs() {
    List<double> outputs = [];
    for (var neuron in neurons) {
      outputs.add(neuron.value);
    }
    return outputs;
  }

  Matrix outputMatrix() {
    return Matrix.column(outputs());
  }
}
