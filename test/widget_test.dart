import 'package:flutter_test/flutter_test.dart';
import 'package:rpl_keamanan/utils/Validators.dart';

void main() {
  test('Validators basic test', () {
    expect(Validators.isValidEmail('test@example.com'), isTrue);
    expect(Validators.isValidEmail('invalid-email'), isFalse);
    expect(Validators.isNotEmpty('Hello'), isTrue);
    expect(Validators.isNotEmpty('   '), isFalse);
  });
}
