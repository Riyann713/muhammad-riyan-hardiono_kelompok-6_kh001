import '../config.dart';
import '../models/user.dart';

/// Service User dengan data lokal (tanpa API / internet).
/// Data disimpan di memori, jadi kembali ke awal saat aplikasi di-restart.
class ApiService {
  // static agar data tetap sama walau ApiService() dibuat berkali-kali
  static final List<User> _users = [
    User(id: 1, name: 'Leanne Graham', email: 'sincere@april.biz', city: 'Gwenborough'),
    User(id: 2, name: 'Ervin Howell', email: 'shanna@melissa.tv', city: 'Wisokyburgh'),
    User(id: 3, name: 'Clementine Bauch', email: 'nathan@yesenia.net', city: 'McKenziehaven'),
    User(id: 4, name: 'Patricia Lebsack', email: 'julianne@kory.org', city: 'South Elvis'),
    User(id: 5, name: 'Chelsey Dietrich', email: 'lucio@annie.ca', city: 'Roscoeview'),
  ];

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  // GET: semua user
  Future<List<User>> getUsers() async {
    await _delay();
    return List.of(_users);
  }

  // GET: satu user berdasarkan ID
  Future<User> getUser(int id) async {
    await _delay();
    final i = _users.indexWhere((u) => u.id == id);
    if (i == -1) throw Exception('User ID $id tidak ditemukan');
    return _users[i];
  }

  // POST: tambah user baru dengan ID dari NIM (1000 + N)
  Future<User> createUser({
    required String name,
    required String email,
    required String city,
  }) async {
    await _delay();
    if (_users.any((u) => u.id == kUserId)) {
      throw Exception('User ID $kUserId sudah ada');
    }
    final user = User(id: kUserId, name: name, email: email, city: city);
    _users.add(user);
    return user;
  }

  // PUT: perbarui nama dan email
  Future<User> updateUser(int id,
      {required String name, required String email}) async {
    await _delay();
    final i = _users.indexWhere((u) => u.id == id);
    if (i == -1) throw Exception('User ID $id tidak ditemukan');
    final updated =
    User(id: id, name: name, email: email, city: _users[i].city);
    _users[i] = updated;
    return updated;
  }

  // PATCH: tambahkan teks " - Flutter Developer" pada nama
  Future<User> patchUserName(int id) async {
    await _delay();
    final i = _users.indexWhere((u) => u.id == id);
    if (i == -1) throw Exception('User ID $id tidak ditemukan');
    final old = _users[i];
    final updated = User(
        id: id,
        name: '${old.name} - Flutter Developer',
        email: old.email,
        city: old.city);
    _users[i] = updated;
    return updated;
  }

  // DELETE: hapus user berdasarkan ID
  Future<void> deleteUser(int id) async {
    await _delay();
    final before = _users.length;
    _users.removeWhere((u) => u.id == id);
    if (_users.length == before) throw Exception('User ID $id tidak ditemukan');
  }
}