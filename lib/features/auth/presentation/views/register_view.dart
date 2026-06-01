// features/auth/presentation/views/register_view.dart
// UI de Registro — incluye campo admin_secret_token.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';
import 'package:kaze_studio_cms/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  static const routeName = '/register';
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey      = GlobalKey<FormState>();
  final _userCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _tokenCtrl    = TextEditingController();
  bool  _obscurePass  = true;
  bool  _obscureToken = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister(AuthViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await vm.register(
      username:         _userCtrl.text.trim(),
      email:            _emailCtrl.text.trim(),
      password:         _passCtrl.text,
      adminSecretToken: _tokenCtrl.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Usuario creado. Inicia sesión.'),
        ),
      );
      Navigator.of(context).pop(); // vuelve a login
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Usuario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sección: Datos del usuario
                          _sectionLabel('Datos del Usuario'),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _userCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de usuario',
                              prefixIcon:
                                  Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) => (v == null || v.length < 3)
                                ? 'Mínimo 3 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon:
                                  Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresa tu correo';
                              }
                              if (!v.contains('@')) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Mínimo 6 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Sección: Token de administrador
                          _sectionLabel('Autorización de Admin'),
                          const SizedBox(height: 4),
                          const Text(
                            'Se requiere el token secreto para crear cuentas.',
                            style: TextStyle(
                                color: Color(0xFF6B6B8A), fontSize: 12),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _tokenCtrl,
                            obscureText: _obscureToken,
                            decoration: InputDecoration(
                              labelText: 'Admin Secret Token',
                              prefixIcon: const Icon(Icons.key_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureToken
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _obscureToken = !_obscureToken),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'El token es requerido'
                                    : null,
                          ),
                          const SizedBox(height: 28),
                          vm.status == AuthStatus.loading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: KazeTheme.neonCyan))
                              : ElevatedButton.icon(
                                  onPressed: () => _onRegister(vm),
                                  icon: const Icon(
                                      Icons.person_add_alt_1_rounded),
                                  label: const Text('CREAR CUENTA'),
                                ),
                          if (vm.status == AuthStatus.error &&
                              vm.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: KazeTheme.errorColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: KazeTheme.errorColor
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                vm.errorMessage!,
                                style: TextStyle(
                                    color: KazeTheme.errorColor,
                                    fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: KazeTheme.deepPurple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: KazeTheme.deepPurple.withValues(alpha: 0.5)),
          ),
          child: const Icon(Icons.person_add_alt_1_rounded,
              color: KazeTheme.neonCyan, size: 28),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registrar Usuario',
                style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Requiere token de administrador',
                style:
                    TextStyle(color: Color(0xFF6B6B8A), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: KazeTheme.neonCyan,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}
