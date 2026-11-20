import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserDetailScreen extends StatelessWidget {
  final int id;
  const UserDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Detail User #$id')),
        body: FutureBuilder<User>(
          future: ApiService().getUser(id),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) return Center(child: Text('${snap.error}'));
            final u = snap.data!;
            return ListView(padding: const EdgeInsets.all(16), children: [
              ListTile(leading: const Icon(Icons.tag), title: const Text('ID'), subtitle: Text('${u.id}')),
              ListTile(leading: const Icon(Icons.person), title: const Text('Nama'), subtitle: Text(u.name)),
              ListTile(leading: const Icon(Icons.email), title: const Text('Email'), subtitle: Text(u.email)),
              ListTile(leading: const Icon(Icons.location_city), title: const Text('Kota'), subtitle: Text(u.city)),
            ]);
          },
        ),
      );
}
