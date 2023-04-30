import 'package:flutter/material.dart';
import 'package:neural_network/classes/NeuralNetwork.dart';
import 'package:neural_network/functions/readData.dart';
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

List<int> layers = [2, 2, 1];

void main() {
  List windData2023 = importData('data/Wind2023.json');
  List windData2022 = importData('data/Wind2022.json');

  trainInputs = windData2022[0];
  trainOutputs = windData2022[1];
  List<List<double>> validateInputs = windData2023[0];
  List<List<double>> validateOutputs = windData2023[1];

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
