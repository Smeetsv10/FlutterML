import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:machine_learning/classes/classes.dart';
import 'package:machine_learning/widgets/neuralnetwork_widget.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  var layout = [2, 4, 4, 1];
  Layer inputLayer = Layer(List.generate(layout[0], (index) => Neuron()));
  Layer hiddenLayer1 = Layer(List.generate(
      layout[1], (index) => Neuron(sizePreviousLayer: layout[0])));
  Layer hiddenLayer2 = Layer(List.generate(
      layout[2], (index) => Neuron(sizePreviousLayer: layout[1])));
  Layer outputLayer = Layer(List.generate(
      layout[3], (index) => Neuron(sizePreviousLayer: layout[2])));

  NeuralNetwork neuralNetwork =
      NeuralNetwork([hiddenLayer1, hiddenLayer2, outputLayer]);

  neuralNetwork.initializeNetwork();

  List<List<double>> inputs = [
    [0, 0],
    [0, 1],
    [1, 0],
    [1, 1],
  ];
  List<List<double>> outputs = [
    [0],
    [0],
    [0],
    [1],
  ];

  List<double> results = neuralNetwork.forward(inputs[0]);
  print(results);

  // Visualize neural Network
  runApp(MyApp(
    neuralNetwork: neuralNetwork,
    inputs: inputs[1],
  ));
}

// -----------------------------------------------------------------------------
// Functions
// -----------------------------------------------------------------------------
Future<List<List<dynamic>>> readCsv(filePath) async {
  String data = await rootBundle.loadString(filePath);
  var converter = const CsvToListConverter();
  List<List<dynamic>> csvList = converter.convert(data);
  return csvList;
}

// -----------------------------------------------------------------------------
// MyApp
// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  final NeuralNetwork neuralNetwork;
  final List<double>? inputs;
  final List<double>? outputs;

  const MyApp(
      {super.key, required this.neuralNetwork, this.inputs, this.outputs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: NeuralNetworkWidget(
        neuralNetwork: neuralNetwork,
        inputs: inputs,
      )),
    );
  }
}
