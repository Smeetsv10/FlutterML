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
  // return value * (1 - value);
  return sigmoid(value) * (1 - sigmoid(value));
}

double reLu(double value) {
  if (value >= 0) {
    return value;
  }
  return 0;
}

double reLuDerivative(double value) {
  if (value >= 0) {
    return 1;
  }
  return 0;
}
