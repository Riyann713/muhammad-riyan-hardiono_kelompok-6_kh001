import 'package:flutter/material.dart';
import '../config.dart';
import '../models/admin.dart';
import '../models/user.dart';
import '../services/admin_service.dart';
import '../services/api_service.dart';
import 'admin_detail_screen.dart';
import 'user_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _adminService = AdminService();
  late Future<List<User>> _users = _api.getUsers();
  late Future<List<Admin>> _admins = _adminService.getAdmins();

  void _reload() => setState(() {
        _users = _api.getUsers();
        _admins = _adminService.getAdmins();
      });

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _run(Future<void> Function() action, String ok) async {
    try {
      await action();
      _msg(ok);
      _reload();
    } catch (e) {
      _msg('Error: $e');
    }
  }

  Future<void> _addUserDialog() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final city = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah User (ID $kUserId)'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: city, decoration: const InputDecoration(labelText: 'Kota')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true) {
      _run(() async {
        await _api.createUser(name: name.text, email: email.text, city: city.text);
      }, 'User ID $kUserId berhasil ditambahkan (POST)');
    }
  }

  Future<void> _editUserDialog(User u) async {
    final name = TextEditingController(text: u.name);
    final email = TextEditingController(text: u.email);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubah User (PUT)'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true) {
      _run(() async {
        await _api.updateUser(u.id, name: name.text, email: email.text);
      }, 'User ${u.id} berhasil diperbarui (PUT)');
    }
  }

  Widget _error(Object? e) => Center(
      child: Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')));

  Widget _usersTab() => FutureBuilder<List<User>>(
        future: _users,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return _error(snap.error);
          final list = snap.data!;
          return ListView(children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                title: const Text('Detail User ID NIM ($kUserId)'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UserDetailScreen(id: kUserId))),
              ),
            ),
            for (final u in list)
              ListTile(
                leading: CircleAvatar(child: Text('${u.id}'.characters.last)),
                title: Text(u.name),
                subtitle: Text('${u.email} • ${u.city}'),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => UserDetailScreen(id: u.id))),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'put') _editUserDialog(u);
                    if (v == 'patch') {
                      _run(() async {
                        await _api.patchUserName(u.id);
                      }, 'Nama user ${u.id} diperbarui (PATCH)');
                    }
                    if (v == 'delete') {
                      _run(() => _api.deleteUser(u.id), 'User ${u.id} dihapus (DELETE)');
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'put', child: Text('Ubah (PUT)')),
                    PopupMenuItem(value: 'patch', child: Text('Tambah " - Flutter Developer" (PATCH)')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus (DELETE)')),
                  ],
                ),
              ),
          ]);
        },
      );

  Widget _adminsTab() => FutureBuilder<List<Admin>>(
        future: _admins,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return _error(snap.error);
          final list = snap.data!;
          return ListView(children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                title: const Text('Detail Admin ID NIM ($kAdminId)'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminDetailScreen(id: kAdminId)));
                  _reload();
                },
              ),
            ),
            for (final a in list)
              ListTile(
                leading: CircleAvatar(child: Text('${a.id}'.characters.last)),
                title: Text(a.name),
                subtitle: Text('${a.email} • ${a.department}'),
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AdminDetailScreen(id: a.id)));
                  _reload();
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _run(
                      () => _adminService.deleteAdmin(a.id), 'Admin ${a.id} dihapus (DELETE)'),
                ),
              ),
          ]);
        },
      );

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('User & Admin (N = $kN)'),
            actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))],
            bottom: const TabBar(tabs: [Tab(text: 'User'), Tab(text: 'Admin')]),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addUserDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('POST User'),
          ),
          body: TabBarView(children: [_usersTab(), _adminsTab()]),
        ),
      );
}
