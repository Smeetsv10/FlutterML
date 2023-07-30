import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:neural_network_v2/classes/NeuralNetwork.dart';
import 'package:provider/provider.dart';

class DataInputPage extends StatelessWidget {
  const DataInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    NeuralNetwork neuralNetwork =
        Provider.of<NeuralNetwork>(context, listen: false);

    Widget inputList = Expanded(
        child: ListView(
      children:
          List.generate(10, (index) => ListTile(title: Text(index.toString()))),
    ));
    Widget outputList = Expanded(child: ListView());

    return Row(
      children: [inputList, outputList],
    );
  }
}
