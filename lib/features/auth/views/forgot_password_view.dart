import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/auth_controller.dart';

/// Pantalla de recuperación de contraseña
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<AuthController>();
    final success = await ctrl.forgotPassword(_emailCtrl.text.trim());
    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _emailSent ? _buildSuccessView() : _buildFormView(ctrl),
      ),
    );
  }

  Widget _buildFormView(AuthController ctrl) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_reset_rounded,
              size: 64, color: Color(0xFF1A237E)),
          const SizedBox(height: 24),
          Text('¿Olvidaste tu contraseña?',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          AppTextField(
            id: 'forgot_email',
            controller: _emailCtrl,
            label: 'Correo electrónico',
            hint: 'tu@correo.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'El correo es requerido';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),
          if (ctrl.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(ctrl.errorMessage!,
                style: const TextStyle(color: Color(0xFFC62828), fontSize: 13)),
          ],
          const SizedBox(height: 24),
          AppButton(
            id: 'forgot_submit_btn',
            label: 'Enviar enlace',
            onPressed: ctrl.isLoading ? null : _handleSubmit,
            isFullWidth: true,
            isLoading: ctrl.isLoading,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Volver al login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_outlined,
            size: 80, color: Color(0xFF2E7D32)),
        const SizedBox(height: 24),
        Text('¡Correo enviado!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Revisa tu bandeja de entrada en ${_emailCtrl.text}. '
          'El enlace expirará en 30 minutos.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AppButton(
          id: 'back_to_login_btn',
          label: 'Volver al login',
          onPressed: () => context.go('/login'),
          isFullWidth: true,
          variant: AppButtonVariant.outlined,
        ),
      ],
    );
  }
}
