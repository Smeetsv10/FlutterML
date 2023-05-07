import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neural_network_v2/classes/NeuralNetwork.dart';
import 'package:neural_network_v2/classes/Neuron.dart';
import 'package:provider/provider.dart';
import 'package:widget_arrows/widget_arrows.dart';

class NeuronWidget extends StatelessWidget {
  final Neuron neuron;
  final Text? popupText;

  const NeuronWidget({super.key, required this.neuron, this.popupText});

  @override
  Widget build(BuildContext context) {
    NeuralNetwork neuralNetwork =
        Provider.of<NeuralNetwork>(context, listen: false);

    List<String> generateTargetIds() {
      List<String> targetIds = [];
      if (neuron.position[0] < neuralNetwork.layers.length) {
        for (var i = 0;
            i <= neuralNetwork.layers[neuron.position[0]].neurons.length;
            i++) {
          targetIds.add('(${neuron.position[0] + 1},$i)');
        }
      }
      return targetIds;
    }

    return GestureDetector(
        onLongPress: popupText == null
            ? () {}
            : () {
                print('longspress');
                // showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         content: popupText,
                //         actions: [
                //           TextButton(
                //             child: const Text("Close"),
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //             },
                //           ),
                //         ],
                //       );
                //     });
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      0,
                      0,
                      0,
                      0,
                    ),
                    items: [PopupMenuItem(child: popupText)]);
              },
        onLongPressEnd: (details) {
          print('ended');
        },
        onTap: () {},
        child: ArrowElement(
          id: '(${neuron.position[0]},${neuron.position[1]})',
          targetIds: generateTargetIds(),
          sourceAnchor: Alignment.centerRight,
          targetAnchor: Alignment.centerLeft,
          bow: 0,
          tipAngleOutwards: pi * 0,
          color: neuron.isActive ? Colors.red : Color.fromARGB(255, 0, 70, 107),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber,
              ),
              child: Text(
                neuron.value.toStringAsFixed(2),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ));
  }
}
