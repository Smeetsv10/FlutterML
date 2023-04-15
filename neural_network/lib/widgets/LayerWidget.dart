import 'package:flutter/material.dart';
import 'package:neural_network/classes/Layer.dart';
import 'package:neural_network/classes/NeuralNetwork.dart';
import 'package:neural_network/widgets/NeuronWidget.dart';
import 'package:provider/provider.dart';

class LayerWidget extends StatelessWidget {
  final Layer layer;
  final int layerNr;

  LayerWidget({Key? key, required this.layer, required this.layerNr});

  @override
  Widget build(BuildContext context) {
    NeuralNetwork neuralNetwork =
        Provider.of<NeuralNetwork>(context, listen: false);

    Text? buildText(int neuronIndex) {
      String outputString = 'sigma(';
      if (layerNr > 0) {
        int numberOfPreviousNodes =
            Provider.of<NeuralNetwork>(context, listen: false)
                .layers[layerNr - 1]
                .outputSize;

        for (var i = 0; i < numberOfPreviousNodes; i++) {
          outputString += neuralNetwork.layers[layerNr].weights[i][neuronIndex]
              .toStringAsFixed(2);
          outputString += 'x';
          outputString += neuralNetwork.layers[layerNr - 1].neurons[i].value
              .toStringAsFixed(2);

          if (i < numberOfPreviousNodes - 1) {
            if (neuralNetwork.layers[layerNr].weights[i + 1][neuronIndex] > 0) {
              outputString += '+';
            }
          } else {
            if (neuralNetwork.layers[layerNr].biases[neuronIndex] > 0) {
              outputString += '+';
            }

            outputString += neuralNetwork.layers[layerNr].biases[neuronIndex]
                .toStringAsFixed(2);
          }
        }
        outputString += ')';
        return Text(outputString);
      }

      return null;
    }

    List<NeuronWidget> neuronWidgetList = List.generate(layer.neurons.length,
        (i) => NeuronWidget(neuron: layer.neurons[i], popupText: buildText(i)));

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: neuronWidgetList,
      ),
    );
  }
}
