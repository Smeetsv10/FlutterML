import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:neural_network_v2/pages/data_input_page.dart';
import 'package:neural_network_v2/widgets/NeuralNetworkWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    int currentPageIndex = 0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assessment)),
              Tab(icon: Icon(Icons.trending_neutral)),
            ],
          ),
          toolbarHeight: 0,
        ),
        body: const TabBarView(
          children: [
            DataInputPage(),
            NeuralNetworkWidget(),
          ],
        ),
      ),
    );
  }
}
