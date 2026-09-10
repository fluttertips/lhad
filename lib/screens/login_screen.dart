import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempsupabaseadmintool/providers/auth_provider.dart';
import 'package:tempsupabaseadmintool/theme/admin_tokens.dart';
import 'package:tempsupabaseadmintool/screens/dashboard_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final auth = context.read<AdminAuthProvider>();
    final ok = auth.login(_userController.text, _passController.text);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();
    return Scaffold(
      backgroundColor: AdminTokens.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: AdminTokens.brand.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.admin_panel_settings_rounded, color: AdminTokens.brand, size: 26),
                  ),
                  const SizedBox(height: 18),
                  const Text('LabHealth Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AdminTokens.ink)),
                  const SizedBox(height: 4),
                  const Text('Sign in to view rider activity & TRF tracking',
                      style: TextStyle(fontSize: 13.5, color: AdminTokens.subtle)),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _userController,
                    decoration: _decoration('Username', Icons.person_outline_rounded),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passController,
                    obscureText: _obscure,
                    decoration: _decoration('Password', Icons.lock_outline_rounded).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19, color: AdminTokens.muted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(auth.error!, style: const TextStyle(color: AdminTokens.danger, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTokens.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                            )
                          : const Text('Sign in', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AdminTokens.muted, fontSize: 14),
      prefixIcon: Icon(icon, color: AdminTokens.brand, size: 20),
      filled: true,
      fillColor: AdminTokens.bg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTokens.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTokens.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTokens.brand, width: 2)),
    );
  }
}
