import 'dart:math';

import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// Classes
// -----------------------------------------------------------------------------
class NeuralNetwork {
  List<Layer> layers;
  double learningRate = 1e-2;

  NeuralNetwork(this.layers);

  List<double> forward(List<double> inputs) {
    var propagatedInputs = inputs;
    for (var layer in layers) {
      propagatedInputs = layer.forward(propagatedInputs);
    }

    return propagatedInputs;
  }

  void initializeNetwork() {
    for (var layer in layers) {
      for (var neuron in layer.neurons) {
        neuron.initializeNeuron();
      }
    }
  }

  void backward(List<double> inputs, List<double> outputs) {
    List<double> estimation = forward(inputs);
    assert(estimation.length == outputs.length);
    List<double> delta = [
      for (var i = 0; i < outputs.length; i++) estimation[i] - outputs[i]
    ];

    // Compute error each layer:
    List<double> errorList = [];
    for (var i = 0; i < layers[layers.length - 1].neurons.length; i++) {
      var neuron = layers[layers.length - 1].neurons[i];
      double error = neuron.backward(delta[i]);
      errorList.add(error);
    }

    for (var i = layers.length - 2; i >= 0; i--) {
      Layer layer = layers[i];
      layer.backward(delta);
    }
  }

  void update_weights() {
    for (var layer in layers) {
      for (var neuron in layer.neurons) {
        neuron.update_weights();
      }
    }
  }
}

class Layer {
  List<Neuron> neurons;
  Layer(this.neurons);

  List<double> forward(List<double> inputs) {
    return [for (var neuron in neurons) neuron.forward(inputs)];
  }

  void backward(List<double> delta) {
    double error = 0;
    List<double> errorList = [];
    for (var i = 0; i < neurons.length; i++) {
      error += neurons[i].backward(delta[i]);
      errorList.add(error);
    }
  }
}

enum ActivationFunction { linear, relu, sigmoid }

class Neuron {
  int sizePreviousLayer = 1;
  List<double>? weights;
  double? bias;
  double? value;
  ActivationFunction activationFunction = ActivationFunction.relu;

  Neuron({this.sizePreviousLayer = 1, this.weights, this.bias, this.value});

  void initializeNeuron() {
    final random = Random();
    bias = 0;
    weights = List.generate(sizePreviousLayer, (index) => random.nextDouble());
  }

  double forward(List<double> inputs) {
    double result = 0.0;

    //assert(inputs.length == weights.length);

    for (var i = 0; i < inputs.length; i++) {
      result += weights![i] * inputs[i];
    }

    result += bias!;

    switch (activationFunction) {
      case ActivationFunction.linear:
        result = result;
        break;
      case ActivationFunction.relu:
        result = relu(result);
        break;
      case ActivationFunction.sigmoid:
        result = sigmoid(result);
        break;

      default:
        break;
    }

    value = result;
    return result;
  }

  double backward(double error) {
    switch (activationFunction) {
      case ActivationFunction.linear:
        return error * 1;
      case ActivationFunction.relu:
        return error * derivative_relu(value!);
      case ActivationFunction.sigmoid:
        return error * derivative_sigmoid(value!);
      default:
        return error;
    }
  }

  void update_weights(List<double> delta, double learningRate) {
    //weights -= learningRate * delta
  }

  double relu(double input) {
    return max(0, input);
  }

  double derivative_relu(double input) {
    if (input < 0) {
      return 0;
    }
    return 1;
  }

  double sigmoid(double input) {
    return 1 / (1 + exp(-input));
  }

  double derivative_sigmoid(double input) {
    return input * (1.0 - input);
  }
}

class TrainingData {
  final List<double> inputs;
  final List<double> outputs;

  TrainingData(this.inputs, this.outputs);
}

class ArrowLine extends CustomPainter {
  final Color color;
  final Offset start;
  final Offset end;

  ArrowLine({required this.color, required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0;

    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    final radius = 10.0;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy)
      ..moveTo(end.dx - radius * cos(angle - pi / 6),
          end.dy - radius * sin(angle - pi / 6))
      ..lineTo(end.dx, end.dy)
      ..lineTo(end.dx - radius * cos(angle + pi / 6),
          end.dy - radius * sin(angle + pi / 6));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
