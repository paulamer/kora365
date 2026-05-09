import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart' as ap;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<ap.AuthProvider>();
    if (_isLogin) {
      auth.signInWithEmail(_emailCtrl.text, _passCtrl.text);
    } else {
      auth.signUpWithEmail(_emailCtrl.text, _passCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Consumer<ap.AuthProvider>(
            builder: (_, auth, __) {
              // Show error snackbar
              if (auth.status == ap.AuthStatus.error && auth.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(auth.errorMessage!),
                      backgroundColor: AppColors.live,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  auth.clearError();
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Center(
                    child: Column(children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppColors.accentGlow, blurRadius: 24, spreadRadius: 4)],
                        ),
                        child: const Icon(Icons.sports_soccer, color: Colors.black, size: 36),
                      ),
                      const SizedBox(height: 16),
                      const Text('MatchTracker',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('Live scores & standings',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ]),
                  ),
                  const SizedBox(height: 48),
                  // Title
                  Text(_isLogin ? 'Welcome back' : 'Create account',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(_isLogin ? 'Sign in to access your favorites' : 'Join to save your favorite matches',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 28),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 20),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textMuted, size: 20),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your password';
                          if (!_isLogin && v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Submit button
                      ElevatedButton(
                        onPressed: auth.status == ap.AuthStatus.loading ? null : _submit,
                        child: auth.status == ap.AuthStatus.loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : Text(_isLogin ? 'Sign In' : 'Create Account'),
                      ),
                      const SizedBox(height: 12),
                      // Divider
                      Row(children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ),
                        Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: 12),
                      // Google sign-in
                      OutlinedButton.icon(
                        onPressed: auth.status == ap.AuthStatus.loading ? null : () => auth.signInWithGoogle(),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 24, color: AppColors.textPrimary),
                        label: const Text('Continue with Google', style: TextStyle(color: AppColors.textPrimary)),
                      ),
                      const SizedBox(height: 24),
                      // Toggle login/signup
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(_isLogin ? "Don't have an account? " : 'Already have an account? ',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        GestureDetector(
                          onTap: () => setState(() { _isLogin = !_isLogin; auth.clearError(); }),
                          child: Text(_isLogin ? 'Sign Up' : 'Sign In',
                              style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ]),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
