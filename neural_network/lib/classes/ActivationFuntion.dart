import 'dart:math';

double linear(double value) {
  return value;
}

double linearDerivative(double value) {
  return 1;
}

double sigmoid(var value) {
  return 1 / (1 + exp(-value));
}

double sigmoidDerivative(double value) {
  return sigmoid(value) * (1 - sigmoid(value));
}

double inverseSigmoid(double value) {
  return -log(1 / value - 1);
}
