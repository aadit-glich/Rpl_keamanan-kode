import 'package:flutter_test/flutter_test.dart';
import 'package:rpl_keamanan/utils/validators.dart';

void main() {
  group('Validators - isValidEmail', () {
    test('Email valid dengan berbagai format domain', () {
      expect(Validators.isValidEmail('sora_sora2@example.com'), isTrue);
      expect(Validators.isValidEmail('r.widyadhana@students.amikom.ac.id'), isTrue);
      expect(Validators.isValidEmail('sora@domain.org'), isTrue);
    });

    test('Email tidak valid jika tidak ada @ atau format domain salah', () {
      expect(Validators.isValidEmail('userexample.com'), isFalse);
      expect(Validators.isValidEmail('user@'), isFalse);
      expect(Validators.isValidEmail('@example.com'), isFalse);
      expect(Validators.isValidEmail('user@example'), isFalse);
      expect(Validators.isValidEmail(''), isFalse);
      expect(Validators.isValidEmail('   '), isFalse);
    });
  });

  group('Validators - sanitize', () {
    test('Mengganti karakter tag script XSS menjadi HTML entities', () {
      final input = "<script>alert('XSS')</script>";
      final sanitized = Validators.sanitize(input);
      expect(sanitized, "&lt;script&gt;alert(&#x27;XSS&#x27;)&lt;/script&gt;");
    });

    test('Mengganti karakter kutip dan tag img berbahaya', () {
      final input = '<img src="x" onerror="alert(1)">';
      final sanitized = Validators.sanitize(input);
      expect(
        sanitized,
        '&lt;img src=&quot;x&quot; onerror=&quot;alert(1)&quot;&gt;',
      );
    });

    test('Mengganti tanda kutip tunggal pada payload injeksi', () {
      final input = "admin' OR '1'='1";
      final sanitized = Validators.sanitize(input);
      expect(sanitized, "admin&#x27; OR &#x27;1&#x27;=&#x27;1");
    });

    test('Membersihkan spasi di awal dan akhir input', () {
      final input = '   <b>konten</b>   ';
      final sanitized = Validators.sanitize(input);
      expect(sanitized, '&lt;b&gt;konten&lt;/b&gt;');
    });
  });

  group('Validators - validateText', () {
    test('Mengembalikan pesan error jika input bernilai null atau kosong', () {
      expect(
        Validators.validateText(null, fieldName: 'Nama'),
        'Nama tidak boleh kosong',
      );
      expect(
        Validators.validateText('', fieldName: 'Nama'),
        'Nama tidak boleh kosong',
      );
      expect(
        Validators.validateText('   ', fieldName: 'Nama'),
        'Nama tidak boleh kosong',
      );
    });

    test('Mengembalikan null jika panjang teks berada dalam batas valid', () {
      expect(
        Validators.validateText('Amikom', minLength: 3, maxLength: 20),
        isNull,
      );
      expect(
        Validators.validateText('Teks valid dengan panjang normal'),
        isNull,
      );
    });

    test('Mengembalikan error jika panjang teks kurang dari minLength', () {
      final result = Validators.validateText(
        'AB',
        fieldName: 'Username',
        minLength: 3,
        maxLength: 10,
      );
      expect(result, 'Username harus antara 3-10 karakter');
    });

    test('Mengembalikan error jika panjang teks melebihi maxLength', () {
      final result = Validators.validateText(
        'TeksIniTerlaluPanjangUntukDiterima',
        fieldName: 'Kode',
        minLength: 1,
        maxLength: 10,
      );
      expect(result, 'Kode harus antara 1-10 karakter');
    });
  });
}
