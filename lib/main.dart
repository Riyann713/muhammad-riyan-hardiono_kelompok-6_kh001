import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/colors.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'widgets/buttons.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _mataKuliahController = TextEditingController();

  static const List<String> _pilihanKehadiran = ['Hadir', 'Izin', 'Sakit'];
  String? _keterangan;

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _lokasiController.dispose();
    _mataKuliahController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengirim data ke Firebase (mengambil nilai dari form)
  Future<void> simpanData() async {
    await FirebaseFirestore.instance.collection('praktikum').add({
      'nama': _namaController.text.trim(),
      'nim': _nimController.text.trim(),
      'lokasi': _lokasiController.text.trim(),
      'mata_kuliah': _mataKuliahController.text.trim(),
      'status': _keterangan,
      'waktu': FieldValue.serverTimestamp(),
    });
  }

  void _kosongkanForm() {
    _namaController.clear();
    _nimController.clear();
    _lokasiController.clear();
    _mataKuliahController.clear();
    _formKey.currentState?.reset(); // juga mengembalikan dropdown ke kosong
    setState(() => _keterangan = null);
  }

  Future<void> _onSimpanPressed() async {
    // Validasi: berhenti jika masih ada field wajib yang kosong
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);

    try {
      await simpanData();
      if (!mounted) return;
      _kosongkanForm();
      messenger.showSnackBar(
        const SnackBar(content: Text('Data berhasil dikirim!')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal mengirim data: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _wajibDiisi(String? value, String namaField) {
    if (value == null || value.trim().isEmpty) {
      return '$namaField wajib diisi';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Design System Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Bagian GitHub =====
            const Text(
              'Akun Github',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tekan tombol di bawah untuk melihat Github saya.',
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Buka Github',
              icon: Icons.location_on,
              url: 'https://github.com/Riyann713',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Tes Tombol',
              icon: Icons.touch_app,
              onPressed: () {
                debugPrint('Tombol berhasil ditekan!');
              },
            ),

            // ===== Bagian Form Firebase =====
            const SizedBox(height: 40),
            const Text(
              'Praktikum Firebase',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Isi data kehadiran di bawah ini, lalu simpan ke Firestore.',
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _wajibDiisi(v, 'Nama'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nimController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'NIM',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _wajibDiisi(v, 'NIM'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lokasiController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _wajibDiisi(v, 'Lokasi'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mataKuliahController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Mata Kuliah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _wajibDiisi(v, 'Mata Kuliah'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _keterangan,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan Kehadiran',
                      border: OutlineInputBorder(),
                    ),
                    items: _pilihanKehadiran
                        .map(
                          (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ),
                    )
                        .toList(),
                    onChanged: (value) => setState(() => _keterangan = value),
                    validator: (v) =>
                    v == null ? 'Keterangan kehadiran wajib dipilih' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _onSimpanPressed,
                icon: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan ke Firebase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}