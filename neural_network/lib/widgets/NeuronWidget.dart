import 'package:flutter/material.dart';
import 'package:neural_network/classes/Neuron.dart';

class NeuronWidget extends StatelessWidget {
  final Neuron neuron;
  final Text? popupText;
  late final ValueNotifier<double> valueNotifier;

  NeuronWidget({required this.neuron, this.popupText}) {
    valueNotifier = ValueNotifier(neuron.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: popupText == null
          ? () {}
          : () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: popupText,
                      actions: [
                        TextButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            },
      child: ValueListenableBuilder(
        valueListenable: valueNotifier,
        builder: (context, value, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber,
              ),
              child: Text(
                value.toStringAsFixed(2),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }
}

void drawArrowBetweenContainers() {}
