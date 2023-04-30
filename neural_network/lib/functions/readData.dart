import 'dart:convert';
import 'dart:io';
import 'dart:math';

List importData(String filePath) {
  List<List<double>> inputData = [];
  List<List<double>> outputData = [];

  final file = File(filePath);
  final contents = file.readAsStringSync();
  final jsonData = jsonDecode(contents);

  for (var i = 0; i < jsonData.length; i++) {
    DateTime dateTime = DateTime.parse(jsonData[i]['datetime']);

    double day = dateTime.day.toDouble();
    double hour = dateTime.hour.toDouble();
    double minute = dateTime.minute.toDouble();

    double encodedDay = sin(day * (2.0 * pi / 365.0));
    double encodedTime =
        sin((hour * 60.0 + minute) * (2.0 * pi / (24.0 * 60.0)));
    double encodedValue = jsonData[i]['generatedpower'];

    inputData.add([encodedDay, encodedTime]);
    outputData.add([encodedValue]);
  }

  return [inputData, outputData];
}
