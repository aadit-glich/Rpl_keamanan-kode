import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/dependency_injector.dart';
import '../services/secure_storage_service.dart';
import '../utils/validators.dart';
import 'post_list_screen.dart';
import 'user_list_screen.dart';
import 'validation_form_screen.dart';

/// Halaman utama aplikasi RPL & Keamanan.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  final TextEditingController _tokenController = TextEditingController();

  String? _savedToken;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _checkToken() async {
    final hasToken = await _storageService.hasToken();
    final token = await _storageService.getToken();
    if (!mounted) return;
    setState(() {
      _hasToken = hasToken;
      _savedToken = token;
    });
  }

  Future<void> _saveToken() async {
    final rawInput = _tokenController.text;
    if (!Validators.isNotEmpty(rawInput)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sanitizedToken = Validators.sanitize(rawInput);
    await _storageService.saveToken(sanitizedToken);
    _tokenController.clear();
    await _checkToken();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token berhasil disimpan di secure storage'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteToken() async {
    await _storageService.deleteToken();
    await _checkToken();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token berhasil dihapus'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String get _tokenPreview {
    final t = _savedToken ?? '';
    return t.length > 10 ? '${t.substring(0, 10)}...' : t;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RPL & Keamanan'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Konfigurasi .env
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'Konfigurasi .env',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Konfigurasi aplikasi dimuat secara aman dari file .env (tanpa hardcoded credential).',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConfig.isConfigured()
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppConfig.isConfigured()
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  AppConfig.isConfigured()
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: AppConfig.isConfigured()
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppConfig.isConfigured()
                                      ? 'Status: Terkonfigurasi (.env valid)'
                                      : 'Status: Konfigurasi belum lengkap',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppConfig.isConfigured()
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Text('Base URL: ${AppConfig.baseUrl}'),
                            const SizedBox(height: 4),
                            Text(
                              'API Key: ${AppConfig.apiKey.isNotEmpty ? "••••••••${AppConfig.apiKey.substring(AppConfig.apiKey.length > 4 ? AppConfig.apiKey.length - 4 : 0)}" : "(Kosong)"}',
                            ),
                            const SizedBox(height: 4),
                            Text('Timeout: ${AppConfig.timeoutSeconds} detik'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Section 2: Secure Storage
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lock, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'Secure Storage',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Simpan token atau PIN di secure storage (terenkripsi AES).',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tokenController,
                        decoration: const InputDecoration(
                          labelText: 'Token',
                          hintText: 'Masukkan token dummy',
                          prefixIcon: Icon(Icons.vpn_key),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveToken,
                              icon: const Icon(Icons.save),
                              label: const Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _hasToken ? _deleteToken : null,
                              icon: const Icon(Icons.delete),
                              label: const Text('Hapus'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _hasToken ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _hasToken ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _hasToken ? Icons.check_circle : Icons.cancel,
                              color: _hasToken ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _hasToken
                                    ? 'Token tersimpan: $_tokenPreview'
                                    : 'Belum ada token tersimpan',
                                style: TextStyle(
                                  color: _hasToken
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Section 3: Repository Pattern & HTTP Request
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Repository Pattern & HTTP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Akses data REST API melalui UserRepository yang mengabstraksi ApiService.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final injector = DependencyInjector.maybeOf(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserListScreen(
                                  repository: injector?.userRepository,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.list),
                          label: const Text('Lihat Daftar Pengguna'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final injector = DependencyInjector.maybeOf(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostListScreen(
                                  repository: injector?.postRepository,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.article),
                          label: const Text('Lihat Daftar Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ValidationFormScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.verified_user),
                          label: const Text('Uji Validasi Form'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Section 4: Catatan Keamanan & Prinsip RPL
              Card(
                color: Colors.amber[50],
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Prinsip RPL & Keamanan Kode',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. SOLID: Single Responsibility, Interface Segregation & Dependency Inversion.\n'
                        '2. Repository Pattern memisahkan logika UI dari akses data (ApiService).\n'
                        '3. Hindari hardcoded credential dengan konfigurasi file .env.\n'
                        '4. Validasi sisi klien dan sanitasi input mencegah eksploitasi.\n'
                        '5. Logging aman: tidak mencetak kredensial atau token sensitif.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
