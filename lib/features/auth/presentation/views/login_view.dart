// features/auth/presentation/views/login_view.dart
// UI de Login — Material 3 Dark Theme, estética de productor.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';
import 'package:kaze_studio_cms/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:kaze_studio_cms/features/auth/presentation/views/register_view.dart';

class LoginView extends StatefulWidget {
  static const routeName = '/login';
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey       = GlobalKey<FormState>();
  final _userCtrl      = TextEditingController();
  final _passCtrl      = TextEditingController();
  bool  _obscurePass   = true;
  late  AnimationController _fadeCtrl;
  late  Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin(AuthViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    await vm.login(
      username: _userCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (vm.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (vm.errorMessage != null) {
      _showSnackbar(vm.errorMessage!);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 40),
                      _buildLoginCard(vm),
                      const SizedBox(height: 20),
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A18),
            Color(0xFF12122A),
            Color(0xFF1A0A2E),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Ícono con efecto glow
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: KazeTheme.deepPurple.withValues(alpha: 0.15),
            border: Border.all(color: KazeTheme.neonCyan, width: 2),
            boxShadow: [
              BoxShadow(
                color: KazeTheme.neonCyan.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.music_note_rounded,
              size: 40, color: KazeTheme.neonCyan),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [KazeTheme.neonCyan, KazeTheme.deepPurple],
          ).createShader(bounds),
          child: const Text(
            'KAZE STUDIO',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
        const Text(
          'CMS  ·  Content Management System',
          style: TextStyle(
            color: Color(0xFF6B6B8A),
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(AuthViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Accede a tu panel de producción',
                style: TextStyle(color: Color(0xFF6B6B8A), fontSize: 13),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  hintText: 'tu_usuario',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingresa tu usuario' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.length < 4) ? 'Mínimo 4 caracteres' : null,
              ),
              const SizedBox(height: 28),
              vm.status == AuthStatus.loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: KazeTheme.neonCyan))
                  : ElevatedButton.icon(
                      onPressed: () => _onLogin(vm),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('ACCEDER'),
                    ),
              if (vm.status == AuthStatus.error &&
                  vm.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KazeTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: KazeTheme.errorColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    vm.errorMessage!,
                    style: TextStyle(
                        color: KazeTheme.errorColor, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('¿No tienes cuenta? ',
            style: TextStyle(color: Color(0xFF6B6B8A))),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(RegisterView.routeName),
          child: const Text('Registrarse'),
        ),
      ],
    );
  }
}
