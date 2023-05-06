import 'package:flutter/material.dart';
import 'package:neural_network_v2/classes/Layer.dart';

class Neuron {
  Layer layer;
  double value;
  List<int> position;
  bool isActive = false;

  Neuron({required this.layer, this.value = 0, this.position = const [0, 0]});
}
