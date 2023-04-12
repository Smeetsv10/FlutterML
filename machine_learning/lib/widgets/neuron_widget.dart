import 'package:flutter/material.dart';
import 'package:machine_learning/classes/classes.dart';

class NeuronWidget extends StatefulWidget {
  final Neuron neuron;
  const NeuronWidget({super.key, required this.neuron});

  @override
  State<NeuronWidget> createState() => _NeuronWidgetState();
}

class _NeuronWidgetState extends State<NeuronWidget> {
  @override
  Widget build(BuildContext context) {
    bool fireNeuron = widget.neuron.value! > 0.5;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
            color: fireNeuron
                ? Colors.amber
                : const Color.fromARGB(255, 63, 60, 60),
            shape: BoxShape.circle),
        child: Text(
          widget.neuron.value.toString(),
          style: TextStyle(
              color: fireNeuron
                  ? Color.fromARGB(255, 63, 60, 60)
                  : Color.fromARGB(255, 255, 245, 172)),
        ),
      ),
    );
  }
}
