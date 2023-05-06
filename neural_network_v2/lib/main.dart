import 'package:flutter/material.dart';
import 'package:neural_network_v2/classes/NeuralNetwork.dart';
import 'package:neural_network_v2/widgets/NeuralNetworkWidget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NeuralNetwork([2, 3, 1])),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NeuralNetworkWidget());
  }
}
