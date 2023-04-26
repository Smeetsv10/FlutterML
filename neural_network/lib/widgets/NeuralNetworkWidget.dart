import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neural_network/classes/NeuralNetwork.dart';
import 'package:neural_network/main.dart';
import 'package:neural_network/widgets/LayerWidget.dart';
import 'package:provider/provider.dart';

class NeuralNetworkWidget extends StatelessWidget {
  const NeuralNetworkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    NeuralNetwork neuralNetwork =
        Provider.of<NeuralNetwork>(context, listen: true);

    List<LayerWidget> buildwidgetList() {
      List<LayerWidget> widgetList = [];
      for (var i = 0; i < neuralNetwork.layers.length; i++) {
        widgetList.add(LayerWidget(layer: neuralNetwork.layers[i], layerNr: i));
      }
      return widgetList;
    }

    List<LayerWidget> widgetList = buildwidgetList();

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Row(
        children: widgetList,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: Text('simulate'),
                ),
                onPressed: () {
                  List<double> input = [
                    Random().nextInt(2).toDouble(),
                    Random().nextInt(2).toDouble(),
                  ];
                  // Calculate new node values
                  neuralNetwork.forward(input);
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: Text('train'),
                ),
                onPressed: () async {
                  List<double> errorList =
                      neuralNetwork.train(trainInputs, trainOutputs);
                  // print(errorList);
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: Text('plotWeights'),
                ),
                onPressed: () {
                  for (var layer in neuralNetwork.layers.sublist(1)) {
                    print('Layer: ${layer.layerNr}');
                    print('Weights: ${layer.weights}');
                    print('Biases: ${layer.biases}\n');
                    print('\n');
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: Text('Randomize'),
                ),
                onPressed: () {
                  for (var layer in neuralNetwork.layers.sublist(1)) {
                    layer.biases = layer.initializeBiases();
                    layer.weights = layer.initializeWeights();
                    print('Layer: ${layer.layerNr}');
                    print('new Weights: ${layer.weights}');
                    print('new Biases: ${layer.biases}\n');
                    print('\n');
                    neuralNetwork.notifyListeners();
                  }
                }),
          ),
        ],
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final List<double> data;
  final double maxData;

  GraphPainter(this.data)
      : maxData = data.reduce((max, value) => max > value ? max : value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    final xStep = size.width / (data.length - 1);
    final yStep = size.height / maxData;

    path.moveTo(0, size.height);

    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - (data[i] * yStep);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
