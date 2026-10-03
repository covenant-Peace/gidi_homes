import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/enums.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  UserRole _role = UserRole.buyer;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _agency = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _agency, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authControllerProvider.notifier);
    if (_isLogin) {
      await auth.signIn(_email.text.trim(), _password.text);
    } else {
      await auth.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
        role: _role,
        agencyName: _agency.text.trim().isEmpty ? null : _agency.text.trim(),
      );
    }
    _afterAuth();
  }

  void _afterAuth() {
    final state = ref.read(authControllerProvider);
    if (state.hasValue && state.value != null) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/account');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final loading = state.isLoading;
    final error = state.hasError ? state.error.toString() : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.location_city_rounded,
                        color: Colors.white, size: 28),
                  ).let((w) => Align(alignment: Alignment.center, child: w)),
                  const SizedBox(height: 20),
                  Text(_isLogin ? 'Welcome back' : 'Create your account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Sign in to manage listings and saved homes.'
                        : 'Join GidiHomes to save homes or list properties.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.slate),
                  ),
                  const SizedBox(height: 28),

                  if (!_isLogin) ...[
                    _RoleToggle(
                      role: _role,
                      onChanged: (r) => setState(() => _role = r),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline)),
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Phone (e.g. +234…)',
                          prefixIcon: Icon(Icons.phone_outlined)),
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    if (_role == UserRole.agent) ...[
                      TextFormField(
                        controller: _agency,
                        decoration: const InputDecoration(
                            labelText: 'Agency / company (optional)',
                            prefixIcon: Icon(Icons.business_outlined)),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],

                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline)),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline)),
                    validator: (v) => (v == null || v.length < 4)
                        ? 'At least 4 characters'
                        : null,
                  ),

                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(error,
                                  style: const TextStyle(
                                      color: AppColors.danger, fontSize: 13))),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: Colors.white))
                          : Text(_isLogin ? 'Sign in' : 'Create account'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or',
                            style: TextStyle(
                                color: AppColors.slate.withValues(alpha: 0.8))),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: loading
                          ? null
                          : () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithGoogle();
                              _afterAuth();
                            },
                      icon: const _GoogleGlyph(),
                      label: const Text('Continue with Google'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: loading
                        ? null
                        : () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .signInDemo();
                            _afterAuth();
                          },
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: const Text('Continue as guest'),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text.rich(TextSpan(
                      text: _isLogin
                          ? "New to GidiHomes? "
                          : 'Already have an account? ',
                      style: const TextStyle(color: AppColors.slate),
                      children: [
                        TextSpan(
                          text: _isLogin ? 'Create one' : 'Sign in',
                          style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    )),
                  ),
                  if (_isLogin)
                    const Text(
                      'Tip: demo@gidihomes.ng · password  (or any seed agent email)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.slate, fontSize: 11.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({required this.role, required this.onChanged});
  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.greenSoft,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (final r in UserRole.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: role == r ? AppColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    r.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: role == r ? Colors.white : AppColors.greenDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

/// Minimal Google "G" mark for the sign-in button.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();
  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
