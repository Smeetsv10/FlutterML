import 'package:flutter/material.dart';
import 'package:neural_network/classes/NeuralNetwork.dart';
import 'package:neural_network/widgets/NeuralNetworkWidget.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// Inputs & Outputs
// -----------------------------------------------------------------------------
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

List<int> layers = [2, 4, 3, 1];

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => NeuralNetwork(layers),
        child: const MaterialApp(
          home: NeuralNetworkWidget(),
          debugShowCheckedModeBanner: false,
        ));
  }
}
