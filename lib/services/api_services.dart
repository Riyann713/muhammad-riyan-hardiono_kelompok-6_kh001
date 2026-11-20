import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String fileName = 'users.json';

  // Mendapatkan path file users.json di internal storage perangkat
  static Future<File> getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  // Mendapatkan path lengkap file JSON dalam bentuk String
  static Future<String> getJsonFilePath() async {
    final file = await getLocalFile();
    return file.path;
  }

  // Inisialisasi file users.json jika belum ada
  static Future<File> _ensureFileInitialized() async {
    final file = await getLocalFile();

    if (!await file.exists()) {
      List<dynamic> initialData = [];
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/users'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          initialData = jsonDecode(response.body);
        }
      } catch (_) {
        // Fallback default data jika offline
        initialData = _defaultUsers;
      }

      if (initialData.isEmpty) {
        initialData = _defaultUsers;
      }

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(initialData),
      );
    }

    return file;
  }

  // Membaca semua data dari file users.json lokal
  static Future<List<dynamic>> _readJsonFile() async {
    final file = await _ensureFileInitialized();
    final contents = await file.readAsString();
    return jsonDecode(contents) as List<dynamic>;
  }

  // Menyimpan seluruh list data kembali ke file users.json lokal
  static Future<void> _writeJsonFile(List<dynamic> users) async {
    final file = await getLocalFile();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(users),
    );
  }

  // GET: Mengambil semua pengguna dari file JSON lokal
  static Future<List<dynamic>> getUsers() async {
    // Simulasi delay singkat agar efek loading tetap terasa realistis
    await Future.delayed(const Duration(milliseconds: 250));
    return await _readJsonFile();
  }

  // GET: Mengambil detail pengguna berdasarkan ID dari file JSON lokal
  static Future<Map<String, dynamic>> getUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final users = await _readJsonFile();

    final user = users.firstWhere(
          (element) => element['id'] == id,
      orElse: () => null,
    );

    if (user != null) {
      return Map<String, dynamic>.from(user);
    }

    throw Exception('Data pengguna dengan ID $id tidak ditemukan');
  }

  // POST: Menambahkan pengguna baru dan menyimpan ke file JSON lokal
  static Future<Map<String, dynamic>> createUser(
      String name,
      String email,
      ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = await _readJsonFile();

    // Generate ID baru (ID terbesar + 1)
    int newId = 1;
    if (users.isNotEmpty) {
      final existingIds = users
          .map<int>((u) => (u['id'] is int ? u['id'] as int : int.tryParse(u['id'].toString()) ?? 0))
          .toList();
      existingIds.sort();
      newId = existingIds.last + 1;
    }

    final newUser = {
      'id': newId,
      'name': name,
      'email': email,
      'address': {
        'city': 'Indonesia',
      },
    };

    users.add(newUser);
    await _writeJsonFile(users);

    return newUser;
  }

  // PUT: Memperbarui seluruh data pengguna dan menyimpannya ke file JSON lokal
  static Future<Map<String, dynamic>> updateUser(
      int id,
      String name,
      String email,
      ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = await _readJsonFile();

    final index = users.indexWhere((element) => element['id'] == id);

    if (index == -1) {
      throw Exception('Gagal memperbarui pengguna: ID $id tidak ditemukan');
    }

    final existing = Map<String, dynamic>.from(users[index]);
    existing['name'] = name;
    existing['email'] = email;

    users[index] = existing;
    await _writeJsonFile(users);

    return existing;
  }

  // PATCH: Memperbarui sebagian data (nama) dan menyimpannya ke file JSON lokal
  static Future<Map<String, dynamic>> patchUser(
      int id,
      String name,
      ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = await _readJsonFile();

    final index = users.indexWhere((element) => element['id'] == id);

    if (index == -1) {
      throw Exception('Gagal mengubah nama pengguna: ID $id tidak ditemukan');
    }

    final existing = Map<String, dynamic>.from(users[index]);
    existing['name'] = name;

    users[index] = existing;
    await _writeJsonFile(users);

    return existing;
  }

  // DELETE: Menghapus pengguna dan menyimpannya ke file JSON lokal
  static Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = await _readJsonFile();

    final index = users.indexWhere((element) => element['id'] == id);

    if (index == -1) {
      return false;
    }

    users.removeAt(index);
    await _writeJsonFile(users);

    return true;
  }

  // Reset data file users.json kembali ke data awal
  static Future<void> resetToDefault() async {
    final file = await getLocalFile();
    if (await file.exists()) {
      await file.delete();
    }
    await _ensureFileInitialized();
  }

  // Default data fallback jika tidak ada koneksi internet saat inisialisasi awal
  static final List<Map<String, dynamic>> _defaultUsers = [
    {
      'id': 1,
      'name': 'Leanne Graham',
      'email': 'Sincere@april.biz',
      'address': {'city': 'Gwenborough'}
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'email': 'Shanna@melissa.tv',
      'address': {'city': 'Wisokyburgh'}
    },
    {
      'id': 3,
      'name': 'Clementine Bauch',
      'email': 'Nathan@yesenia.net',
      'address': {'city': 'McKenziehaven'}
    },
    {
      'id': 4,
      'name': 'Patricia Lebsack',
      'email': 'Julianne.OConner@kory.org',
      'address': {'city': 'South Elvis'}
    },
    {
      'id': 5,
      'name': 'Chelsey Dietrich',
      'email': 'Lucio_Hettinger@annie.ca',
      'address': {'city': 'Roscoeview'}
    },
    {
      'id': 6,
      'name': 'Mrs. Dennis Schulist',
      'email': 'Karley_Dach@jasper.info',
      'address': {'city': 'South Christy'}
    },
    {
      'id': 7,
      'name': 'Kurtis Weissnat',
      'email': 'Telly.Hoeger@billy.biz',
      'address': {'city': 'Howemouth'}
    },
    {
      'id': 8,
      'name': 'Nicholas Runolfsdottir V',
      'email': 'Sherwood@rosamond.me',
      'address': {'city': 'Aliyaview'}
    },
    {
      'id': 9,
      'name': 'Glenna Reichert',
      'email': 'Chaim_McDermott@dana.io',
      'address': {'city': 'Bartholomebury'}
    },
    {
      'id': 10,
      'name': 'Clementina DuBuque',
      'email': 'Rey.Padberg@karina.biz',
      'address': {'city': 'Lebsackbury'}
    },
  ];
}