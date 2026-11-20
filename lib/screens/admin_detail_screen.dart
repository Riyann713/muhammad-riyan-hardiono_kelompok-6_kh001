import 'package:flutter/material.dart';
import '../models/admin.dart';
import '../services/admin_service.dart';

class AdminDetailScreen extends StatelessWidget {
  final int id;
  const AdminDetailScreen({super.key, required this.id});

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Admin'),
        content: Text('Yakin menghapus admin ID $id?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminService().deleteAdmin(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Admin $id berhasil dihapus')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Detail Admin #$id')),
        body: FutureBuilder<Admin>(
          future: AdminService().getAdmin(id),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) return Center(child: Text('${snap.error}'));
            final a = snap.data!;
            return ListView(padding: const EdgeInsets.all(16), children: [
              ListTile(leading: const Icon(Icons.tag), title: const Text('ID'), subtitle: Text('${a.id}')),
              ListTile(leading: const Icon(Icons.person), title: const Text('Nama'), subtitle: Text(a.name)),
              ListTile(leading: const Icon(Icons.email), title: const Text('Email'), subtitle: Text(a.email)),
              ListTile(leading: const Icon(Icons.business), title: const Text('Department'), subtitle: Text(a.department)),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _delete(context),
                icon: const Icon(Icons.delete),
                label: const Text('Hapus Admin'),
              ),
            ]);
          },
        ),
      );
}
