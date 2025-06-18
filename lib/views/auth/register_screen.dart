import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              children: [
                const Icon(Icons.eco, size: 80, color: Colors.white),
                const SizedBox(height: 16, ),
                const Text('Invernadero IoT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  )),
                const SizedBox(height: 8),
                const Text('Crear Cuenta',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  )),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInput(
                        controller: _emailCtrl,
                        hint: 'Correo electrónico',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Email inválido' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        controller: _passCtrl,
                        hint: 'Contraseña',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (v) =>
                          (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        controller: _confirmCtrl,
                        hint: 'Confirmar Contraseña',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v != _passCtrl.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print('Registrando usuario: ${_emailCtrl.text}');
                      final vm = context.read<LoginViewModel>();
                      vm.register(_emailCtrl.text, _passCtrl.text).then((user) {
                        if (user != null) {
                          // Navegamos a la pantalla de perfil después del registro exitoso
                          // Esto es importante para que el usuario complete su perfil después de registrarse
                          Navigator.pushReplacementNamed(context, '/profile');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(vm.error ?? 'Error al registrarse')),
                          );
                        }
                      });
                    }
                  },
                  child: Text(
                    'Registrarse',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}
