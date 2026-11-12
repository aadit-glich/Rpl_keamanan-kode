import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpl_keamanan/config/dependency_injector.dart';
import 'package:rpl_keamanan/models/post.dart';
import 'package:rpl_keamanan/services/api_service.dart';
import 'package:rpl_keamanan/utils/logger.dart';
import 'package:rpl_keamanan/utils/validators.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(
      fileInput: 'BASE_URL=https://jsonplaceholder.typicode.com\nAPI_KEY=test_key\n',
    );
  });

  test('Validators basic test', () {
    expect(Validators.isValidEmail('test@example.com'), isTrue);
    expect(Validators.isValidEmail('invalid-email'), isFalse);
    expect(Validators.isNotEmpty('Hello'), isTrue);
    expect(Validators.isNotEmpty('   '), isFalse);
  });

  test('Phone validation test', () {
    expect(Validators.validatePhone('08123456789'), isNull);
    expect(Validators.validatePhone('0812345678901'), isNull);
    expect(Validators.validatePhone('081234567'), isNotNull);
    expect(Validators.validatePhone('0812345678901234'), isNotNull);
    expect(Validators.validatePhone('0812345678a'), isNotNull);
    expect(Validators.validatePhone(''), isNotNull);
  });

  test('URL validation test', () {
    expect(Validators.validateUrl('http://example.com'), isNull);
    expect(Validators.validateUrl('https://amikom.ac.id'), isNull);
    expect(Validators.validateUrl('ftp://example.com'), isNotNull);
    expect(Validators.validateUrl('amikom.ac.id'), isNotNull);
    expect(Validators.validateUrl(''), isNotNull);
  });

  test('Password validation test', () {
    expect(Validators.validatePassword('Password123!'), isNull);
    expect(Validators.validatePassword('Secret9#'), isNull);
    expect(Validators.validatePassword('Pass1!'), isNotNull); // < 8 chars
    expect(Validators.validatePassword('password123!'), isNotNull); // no uppercase
    expect(Validators.validatePassword('Password!!!!'), isNotNull); // no number
    expect(Validators.validatePassword('Password1234'), isNotNull); // no symbol
    expect(Validators.validatePassword(''), isNotNull);
  });

  test('Structured Logger test', () {
    expect(() => Logger.debug('Debug message', 'TestTag'), returnsNormally);
    expect(() => Logger.info('Info message', 'TestTag'), returnsNormally);
    expect(() => Logger.warning('Warning message', 'TestTag'), returnsNormally);
    expect(
      () => Logger.error('Error message', Exception('Test error'), null, 'TestTag'),
      returnsNormally,
    );
  });

  test('Post model fromJson test', () {
    final json = {
      'userId': 1,
      'id': 101,
      'title': 'Test Title',
      'body': 'Test Body',
    };
    final post = Post.fromJson(json);
    expect(post.userId, 1);
    expect(post.id, 101);
    expect(post.title, 'Test Title');
    expect(post.body, 'Test Body');
  });

  test('ApiService singleton pattern test', () {
    final instance1 = ApiService();
    final instance2 = ApiService.instance;
    expect(identical(instance1, instance2), isTrue);
  });

  testWidgets('DependencyInjector provides dependencies in widget tree',
      (tester) async {
    late ApiService service;
    await tester.pumpWidget(
      DependencyInjector(
        child: Builder(
          builder: (context) {
            service = DependencyInjector.of(context).apiService;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(service, isNotNull);
  });
}
