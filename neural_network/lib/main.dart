import 'package:flutter/material.dart';
import 'package:neural_network/classes/NeuralNetwork.dart';
import 'package:neural_network/widgets/NeuralNetworkWidget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

// -----------------------------------------------------------------------------
// Classes
// ------------------------------------------------------------- ----------------
List<List<double>> trainInputs = [
  [0, 0],
  [1, 0],
  [0, 1],
  [1, 1],
];
List<List<double>> trainOutputs = [
  [0],
  [1],
  [1],
  [0],
];
// List<List<double>> trainInputs = [
//   [1, 0],
// ];
// List<List<double>> trainOutputs = [
//   [1],
// ];

// -----------------------------------------------------------------------------
// Widgets
// -----------------------------------------------------------------------------
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => NeuralNetwork([2, 3, 1]),
        child: const MaterialApp(home: NeuralNetworkWidget()));
  }
}
