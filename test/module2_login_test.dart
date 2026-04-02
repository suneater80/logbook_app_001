import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';

void main() {
  group('Module 2 - LoginController', () {
    late LoginController controller;

    setUp(() {
      controller = LoginController();
    });

    test('TC01 - login should return true for admin valid credential', () {
      final actual = controller.login('admin', '123');
      const expected = true;

      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('TC02 - login should return true for user1 valid credential', () {
      final actual = controller.login('user1', 'pass1');
      const expected = true;

      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('TC03 - login should return true for hakim valid credential', () {
      final actual = controller.login('hakim', 'hakim123');
      const expected = true;

      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('TC04 - login should return false for wrong password', () {
      final actual = controller.login('admin', '321');
      const expected = false;

      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('TC05 - login should return false for unknown username', () {
      final actual = controller.login('guest', '123');
      const expected = false;

      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test(
      'TC06 - login should return false for invalid username and password',
      () {
        final actual = controller.login('x', 'y');
        const expected = false;

        expect(actual, expected, reason: 'Expected $expected but got $actual');
      },
    );

    test('TC07 - login should return false when username is empty', () {
      final actual = controller.login('', '123');
      const expected = false;

      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('TC08 - login should return false when password is empty', () {
      final actual = controller.login('admin', '');
      const expected = false;

      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('TC09 - login should return false for uppercase username', () {
      final actual = controller.login('ADMIN', '123');
      const expected = false;

      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test(
      'TC10 - login should return false for username with trailing space',
      () {
        final actual = controller.login('admin ', '123');
        const expected = false;

        expect(actual, expected, reason: 'Expected $expected but got $actual');
      },
    );
  });
}
