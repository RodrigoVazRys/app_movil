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
  bool  _obscurePass  = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister(AuthViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await vm.register(
      username:         _userCtrl.text.trim(),
      email:            _emailCtrl.text.trim(),
      password:         _passCtrl.text,
      adminSecretToken: 'NKCyFzsvm70Zno5fQvxNu-DzVwBSvvinyPrqpGnEm_M',
    );

    if (!mounted) return;
    if (success) {
      _showVerificationDialog(vm);
    }
  }

  void _showVerificationDialog(AuthViewModel vm) {
    final codeCtrl = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF16162C),
            title: const Text('Verifica tu correo', style: TextStyle(color: KazeTheme.neonCyan)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ingresa el código de 6 dígitos que enviamos a tu email.', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Código (ej. AB123C)', prefixIcon: Icon(Icons.security_rounded)),
                  textCapitalization: TextCapitalization.characters,
                ),
                if (vm.status == AuthStatus.error && vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isVerifying ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: isVerifying ? null : () async {
                  setState(() => isVerifying = true);
                  final success = await vm.verifyEmail(codeCtrl.text.trim());
                  if (success) {
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('✅ Cuenta creada. Ya puedes iniciar sesión.')),
                      );
                      Navigator.of(this.context).pop(); // vuelve a login
                    }
                  } else {
                    setState(() => isVerifying = false);
                  }
                },
                child: isVerifying 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('Verificar'),
              ),
            ],
          );
        }
      ),
    );
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
