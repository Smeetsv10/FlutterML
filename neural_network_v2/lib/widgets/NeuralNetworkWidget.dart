import 'package:flutter/material.dart';
import 'package:neural_network_v2/classes/Activationfunction.dart';
import 'package:neural_network_v2/classes/NeuralNetwork.dart';
import 'package:neural_network_v2/widgets/LayerWidget.dart';
import 'package:provider/provider.dart';
import 'package:widget_arrows/widget_arrows.dart';

class NeuralNetworkWidget extends StatefulWidget {
  const NeuralNetworkWidget({super.key});

  @override
  State<NeuralNetworkWidget> createState() => _NeuralNetworkWidgetState();
}

class _NeuralNetworkWidgetState extends State<NeuralNetworkWidget> {
  @override
  Widget build(BuildContext context) {
    NeuralNetwork neuralNetwork =
        Provider.of<NeuralNetwork>(context, listen: true);
    final GlobalKey nnkey = GlobalKey();

    Widget predictButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: Container(
          width: 100,
          alignment: Alignment.center,
          child: const Text('Predict'),
        ),
        onPressed: () {
          neuralNetwork.forward([0, 1]);
        },
      ),
    );
    Widget randomizeButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: Container(
          width: 100,
          alignment: Alignment.center,
          child: const Text('Randomize'),
        ),
        onPressed: () {
          for (var layer in neuralNetwork.layers) {
            layer.initializeBiases();
            layer.initializeWeights();
            print('Layer: ${layer.inputSize} -> ${layer.outputSize}');
            print('new Weights: ${layer.weights}');
            print('new Biases: ${layer.biases}\n');
            print('\n');
            neuralNetwork.notifyListeners();
          }
        },
      ),
    );

    List<LayerWidget> buildwidgetList() {
      List<LayerWidget> widgetList = [];
      for (var i = 0; i < neuralNetwork.layers.length; i++) {
        widgetList.add(LayerWidget(
          key: nnkey,
          layer: neuralNetwork.layers[i],
        ));
      }
      return widgetList;
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Stack(
        children: [
          ArrowContainer(child: Row(children: buildwidgetList())),
          Visibility(
            visible: neuralNetwork.isTraining,
            child: const AlertDialog(
              content: Text('Updating weights and biases...'),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          predictButton,
          randomizeButton,
        ],
      ),
    );
  }
}
