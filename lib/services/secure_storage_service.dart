import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service untuk mengelola penyimpanan aman menggunakan FlutterSecureStorage.
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Key yang digunakan
  static const String _tokenKey = 'auth_token';
  static const String _pinKey = 'user_pin';

  /// Menyimpan token ke secure storage.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // Logging aman: tidak mencetak token
    print('Token berhasil disimpan');
  }

  /// Membaca token dari secure storage.
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    // Logging aman: hanya status
    print(token != null ? 'Token ditemukan' : 'Token tidak ditemukan');
    return token;
  }

  /// Menghapus token dari secure storage.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    print('Token berhasil dihapus');
  }

  /// Menyimpan PIN ke secure storage.
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    print('PIN berhasil disimpan');
  }

  /// Membaca PIN dari secure storage.
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  /// Menghapus semua data dari secure storage.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    print('Semua data berhasil dihapus');
  }

  /// Memeriksa keberadaan token di secure storage.
  Future<bool> hasToken() async {
    return await _storage.containsKey(key: _tokenKey);
  }
}
