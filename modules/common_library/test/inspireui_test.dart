import 'package:flutter_test/flutter_test.dart';

// import 'package:instasoft/instasoft.dart';

void main() {
  Calculator() {}
  test('adds one to input values', () {
    final dynamic calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
    expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });
}
