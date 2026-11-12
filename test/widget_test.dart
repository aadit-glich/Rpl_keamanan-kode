import 'package:flutter_test/flutter_test.dart';
import 'package:rpl_keamanan/models/post.dart';
import 'package:rpl_keamanan/utils/validators.dart';

void main() {
  test('Validators basic test', () {
    expect(Validators.isValidEmail('test@example.com'), isTrue);
    expect(Validators.isValidEmail('invalid-email'), isFalse);
    expect(Validators.isNotEmpty('Hello'), isTrue);
    expect(Validators.isNotEmpty('   '), isFalse);
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
}
