import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundGradient(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: ProfileHeader(user: user),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.separated(
                      itemCount: _ProfileField.values.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, idx) {
                        final field = _ProfileField.values[idx];
                        final value = field.getValue(user);
                        return InfoCard(
                          icon: field.icon,
                          label: field.label,
                          value: value,
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: LogoutButton(onLogout: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content:
                            const Text('¿Estás seguro que deseas cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Cerrar Sesión',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await loginVM.logout();
                      if (context.mounted) {
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/login', (_) => false);
                      }
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final User? user;
  const ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : user?.email ?? 'Usuario';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: user?.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    user!.photoURL!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.person, size: 60, color: Colors.green.shade700),
        ),
        const SizedBox(height: 12),
        const Text(
          'Bienvenido,',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

enum _ProfileField {
  email(Icons.email, 'Email'),
  uid(Icons.perm_identity, 'UID'),
  phone(Icons.phone, 'Teléfono');

  final IconData icon;
  final String label;
  const _ProfileField(this.icon, this.label);

  String getValue(User? user) {
    switch (this) {
      case _ProfileField.email:
        return user?.email ?? 'No disponible';
      case _ProfileField.uid:
        return user?.uid ?? 'No disponible';
      case _ProfileField.phone:
        return user?.phoneNumber ?? 'No disponible';
    }
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Icon(icon, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Text(
              '$label:',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final Future<void> Function() onLogout;
  const LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text('Cerrar Sesión'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: onLogout,
    );
  }
}
