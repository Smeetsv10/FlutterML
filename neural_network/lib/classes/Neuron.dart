import 'package:flutter/material.dart';
import 'package:neural_network/classes/NeuralNetwork.dart';

class Neuron extends ChangeNotifier {
  double _value;
  List<int> _coordinate; // [layerNr, neuronNr]
  final NeuralNetwork neuralNetwork;

  double get value => _value;
  List<int> get coordinate => _coordinate;

  Neuron(this.neuralNetwork, this._value, this._coordinate);

  void setValue(double newValue) {
    if (_value != newValue) {
      _value = newValue;
      neuralNetwork.notifyListeners();
    }
  }
}
