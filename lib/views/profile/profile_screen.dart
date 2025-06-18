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
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar de usuario
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: user?.photoURL != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            user!.photoURL!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.person, size: 60, color: Colors.green.shade700),
                ),
                const SizedBox(height: 16),

                const Text('Bienvenido,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  )),
                const SizedBox(height: 8),

                Text(
                  user?.displayName ?? user?.email ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                _InfoCard(
                  icon: Icons.email,
                  label: 'Email', 
                  value: user?.email ?? 'No disponible'
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.perm_identity,
                  label: 'UID',   
                  value: user?.uid ?? 'No disponible'
                ),
                if (user?.phoneNumber != null) ...[
                  const SizedBox(height: 16),
                  _InfoCard(
                    icon: Icons.phone,
                    label: 'Teléfono', 
                    value: user!.phoneNumber!
                  ),
                ],
                
                const Spacer(),
                
                // Botón de cerrar sesión
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    // Mostrar diálogo de confirmación
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
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
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    }
                  },
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _InfoCard({
    required this.icon,
    required this.label, 
    required this.value
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
