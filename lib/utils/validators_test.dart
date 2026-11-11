import 'package:flutter_test/flutter_test.dart';

import 'validators.dart';

void main() {
  // ===== a) Test isValidEmail() =====
  group('Validators.isValidEmail', () {
    test('menerima email standar', () {
      expect(Validators.isValidEmail('user@example.com'), isTrue);
    });

    test('menerima email dengan subdomain', () {
      expect(Validators.isValidEmail('nama.belakang@mail.univ.ac.id'), isTrue);
    });

    test('menerima email dengan tanda plus', () {
      expect(Validators.isValidEmail('user+tag@example.co.id'), isTrue);
    });

    test('menolak email tanpa simbol @', () {
      expect(Validators.isValidEmail('userexample.com'), isFalse);
    });

    test('menolak email tanpa domain lengkap', () {
      expect(Validators.isValidEmail('user@example'), isFalse);
    });

    test('menolak email tanpa bagian lokal', () {
      expect(Validators.isValidEmail('@example.com'), isFalse);
    });

    test('menolak email dengan dua simbol @', () {
      expect(Validators.isValidEmail('user@@example.com'), isFalse);
    });

    test('menolak email dengan titik di akhir domain', () {
      expect(Validators.isValidEmail('user@example.'), isFalse);
    });

    test('menolak string kosong', () {
      expect(Validators.isValidEmail(''), isFalse);
    });
  });

  // ===== b) Test sanitize() =====
  group('Validators.sanitize', () {
    test('mengganti tag script dengan HTML entities', () {
      expect(
        Validators.sanitize('<script>alert("x")</script>'),
        '&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;',
      );
    });

    test('mengganti karakter kurang dari dan lebih dari', () {
      final result = Validators.sanitize('<img src="x">');

      expect(result, isNot(contains('<')));
      expect(result, isNot(contains('>')));
    });

    test('mengganti tanda kutip tunggal', () {
      expect(Validators.sanitize("' OR '1'='1"), '&#39; OR &#39;1&#39;=&#39;1');
    });

    test('mengganti tanda kutip ganda', () {
      expect(Validators.sanitize('"quoted"'), '&quot;quoted&quot;');
    });

    test('menghapus spasi di awal dan akhir', () {
      expect(Validators.sanitize('  hello  '), 'hello');
    });

    test('tidak mengubah teks aman', () {
      expect(Validators.sanitize('Budi Santoso'), 'Budi Santoso');
    });

    test('string kosong tetap kosong', () {
      expect(Validators.sanitize(''), '');
    });
  });

  // ===== c) Test validateText() =====
  group('Validators.validateText', () {
    test('null menghasilkan pesan tidak boleh kosong', () {
      expect(Validators.validateText(null), 'Field tidak boleh kosong');
    });

    test('string kosong ditolak', () {
      expect(Validators.validateText(''), 'Field tidak boleh kosong');
    });

    test('string spasi saja dianggap kosong', () {
      expect(Validators.validateText('   '), 'Field tidak boleh kosong');
    });

    test('menggunakan nama field khusus', () {
      expect(
        Validators.validateText('', fieldName: 'Nama'),
        'Nama tidak boleh kosong',
      );
    });

    test('1 karakter valid', () {
      expect(Validators.validateText('a'), isNull);
    });

    test('100 karakter valid', () {
      expect(Validators.validateText('a' * 100), isNull);
    });

    test('101 karakter ditolak', () {
      expect(
        Validators.validateText('a' * 101),
        'Field harus antara 1-100 karakter',
      );
    });

    test('kurang dari minLength ditolak', () {
      expect(
        Validators.validateText(
          'ab',
          fieldName: 'Nama',
          minLength: 3,
          maxLength: 50,
        ),
        'Nama harus antara 3-50 karakter',
      );
    });

    test('tepat minLength valid', () {
      expect(
        Validators.validateText(
          'abc',
          fieldName: 'Nama',
          minLength: 3,
          maxLength: 50,
        ),
        isNull,
      );
    });

    test('tepat maxLength valid', () {
      expect(
        Validators.validateText(
          'a' * 50,
          fieldName: 'Nama',
          minLength: 3,
          maxLength: 50,
        ),
        isNull,
      );
    });

    test('melebihi maxLength ditolak', () {
      expect(
        Validators.validateText(
          'a' * 51,
          fieldName: 'Nama',
          minLength: 3,
          maxLength: 50,
        ),
        'Nama harus antara 3-50 karakter',
      );
    });

    test('panjang dihitung setelah trim', () {
      expect(
        Validators.validateText(
          '  ab  ',
          fieldName: 'Nama',
          minLength: 3,
          maxLength: 50,
        ),
        'Nama harus antara 3-50 karakter',
      );
    });
  });
}
