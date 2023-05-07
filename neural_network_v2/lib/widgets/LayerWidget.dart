import 'package:flutter/material.dart';
import 'package:neural_network_v2/classes/Layer.dart';
import 'package:neural_network_v2/classes/NeuralNetwork.dart';
import 'package:neural_network_v2/widgets/NeuronWidget.dart';
import 'package:provider/provider.dart';

class LayerWidget extends StatelessWidget {
  final Layer layer;

  LayerWidget({Key? key, required this.layer});

  @override
  Widget build(BuildContext context) {
    NeuralNetwork neuralNetwork =
        Provider.of<NeuralNetwork>(context, listen: false);

    Text? buildText(int neuronIndex) {
      String outputString = 'sigma(';
      if (layer.layerNr > 0) {
        int numberOfPreviousNodes =
            Provider.of<NeuralNetwork>(context, listen: false)
                .layers[layer.layerNr - 1]
                .outputSize;

        for (var i = 0; i < numberOfPreviousNodes; i++) {
          outputString += neuralNetwork
              .layers[layer.layerNr].weights[i][neuronIndex]
              .toStringAsFixed(2);
          outputString += 'x';
          outputString += neuralNetwork
              .layers[layer.layerNr - 1].neurons[i].value
              .toStringAsFixed(2);

          if (i < numberOfPreviousNodes - 1) {
            if (neuralNetwork.layers[layer.layerNr].weights[i + 1]
                    [neuronIndex] >
                0) {
              outputString += '+';
            }
          } else {
            if (neuralNetwork.layers[layer.layerNr].biases[neuronIndex] >= 0) {
              outputString += '+';
            }

            outputString += neuralNetwork
                .layers[layer.layerNr].biases[neuronIndex]
                .toStringAsFixed(2);
          }
        }
        outputString += ')';
        return Text(outputString);
      }

      return null;
    }

    List<NeuronWidget> neuronWidgetList = List.generate(
        layer.outputSize,
        (i) => NeuronWidget(
              neuron: layer.neurons[i],
              popupText: buildText(i),
            ));

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: neuronWidgetList,
      ),
    );
  }
}
