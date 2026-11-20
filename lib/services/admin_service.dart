import '../models/admin.dart';

/// Service Admin dengan data lokal (tanpa API / internet).
class AdminService {
  static final List<Admin> _admins = [
    Admin(id: 2001, name: 'Budi Santoso', email: 'budi@kampus.ac.id', department: 'IT Support'),
    Admin(id: 2002, name: 'Siti Aminah', email: 'siti@kampus.ac.id', department: 'Akademik'),
    // ID Admin sesuai NIM: 2000 + 112 = 2112
    Admin(id: 2112, name: 'Muhammad Riyan Hardiono', email: 'riyan@kampus.ac.id', department: 'Teknologi Informasi'),
  ];

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  // GET: seluruh admin
  Future<List<Admin>> getAdmins() async {
    await _delay();
    return List.of(_admins);
  }

  // GET: satu admin berdasarkan ID
  Future<Admin> getAdmin(int id) async {
    await _delay();
    final i = _admins.indexWhere((a) => a.id == id);
    if (i == -1) throw Exception('Admin ID $id tidak ditemukan');
    return _admins[i];
  }

  // DELETE: hapus admin berdasarkan ID
  Future<void> deleteAdmin(int id) async {
    await _delay();
    final before = _admins.length;
    _admins.removeWhere((a) => a.id == id);
    if (_admins.length == before) throw Exception('Admin ID $id tidak ditemukan');
  }
}