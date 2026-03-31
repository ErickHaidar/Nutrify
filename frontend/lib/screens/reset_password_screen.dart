import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _newPassVisible = false;
  bool _confirmPassVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final newPass = _newPasswordCtrl.text.trim();
    final confirmPass = _confirmPasswordCtrl.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showError('Semua field harus diisi');
      return;
    }
    if (newPass.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }
    if (newPass != confirmPass) {
      _showError('Password dan konfirmasi tidak cocok');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPass),
      );
      if (!mounted) return;
      FlushbarHelper.createSuccess(
        message: 'Password berhasil diperbarui. Silakan login.',
        title: 'Berhasil!',
        duration: const Duration(seconds: 3),
      ).show(context).then((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.login,
            (route) => false,
          );
        }
      });
    } on AuthException catch (e) {
      _showError(e.message.isNotEmpty ? e.message : 'Gagal memperbarui password');
    } catch (_) {
      _showError('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    FlushbarHelper.createError(
      message: msg,
      title: 'Error',
      duration: const Duration(seconds: 3),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrifyTheme.background,
      appBar: AppBar(
        backgroundColor: NutrifyTheme.darkCard,
        elevation: 0,
        title: Text(
          'Buat Password Baru',
          style: GoogleFonts.montserrat(
            color: NutrifyTheme.accentOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Password Baru',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _newPasswordCtrl,
                hint: 'Masukkan password baru',
                visible: _newPassVisible,
                onToggle: () =>
                    setState(() => _newPassVisible = !_newPassVisible),
              ),
              const SizedBox(height: 20),
              Text(
                'Konfirmasi Password',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _confirmPasswordCtrl,
                hint: 'Ulangi password baru',
                visible: _confirmPassVisible,
                onToggle: () => setState(
                    () => _confirmPassVisible = !_confirmPassVisible),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NutrifyTheme.accentOrange,
                    disabledBackgroundColor:
                        NutrifyTheme.accentOrange.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: NutrifyTheme.darkCard,
                          ),
                        )
                      : Text(
                          'Simpan Password',
                          style: TextStyle(
                            color: NutrifyTheme.darkCard,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: !visible,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey[600],
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
