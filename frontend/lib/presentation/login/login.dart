import 'package:another_flushbar/flushbar_helper.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/constants/assets.dart';
import 'package:nutrify/core/stores/form/form_store.dart';
import 'package:nutrify/core/widgets/empty_app_bar_widget.dart';
import 'package:nutrify/core/widgets/progress_indicator_widget.dart';
import 'package:nutrify/data/sharedpref/constants/preferences.dart';
import 'package:nutrify/presentation/login/store/login_store.dart';
import 'package:nutrify/utils/device/device_utils.dart';
import 'package:nutrify/utils/locale/app_localization.dart';
import 'package:nutrify/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart' as mobx;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../di/service_locator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;

  // visibility toggles:--------------------------------------------------------
  bool _loginPasswordVisible = false;

  late List<mobx.ReactionDisposer> _disposers;
  
  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();

    // Reaksi otomatis saat login/signup berhasil
    _disposers = [
      mobx.reaction((_) => _userStore.success, (bool success) {
        if (success && mounted) {
          _handleNavigation();
        }
      }),
      mobx.reaction((_) => _userStore.errorStore.errorMessage, (String message) {
        if (message.isNotEmpty && mounted) {
          _showErrorMessage(message);
        }
      }),
      mobx.reaction((_) => _formStore.errorStore.errorMessage, (String message) {
        if (message.isNotEmpty && mounted) {
          _showErrorMessage(message);
        }
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: _buildBody(),
      backgroundColor: NutrifyTheme.background,
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        Center(child: _buildRightSide()),
        // Removing the old Observer-based error side effect which caused assertion errors
        Observer(
          builder: (context) {
            return Visibility(
              visible: _userStore.isLoading,
              child: CustomProgressIndicatorWidget(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 60),
            _buildLogo(),
            SizedBox(height: 16),
            _buildTitle(),
            SizedBox(height: 8),
            _buildSubtitle(),
            SizedBox(height: 48),
            _buildEmailField(),
            SizedBox(height: 16),
            _buildPasswordField(),
            _buildForgotPasswordButton(),
            SizedBox(height: 24),
            _buildSignInButton(),
            SizedBox(height: 32),
            _buildOrDivider(),
            SizedBox(height: 32),
            _buildSocialButtons(),
            SizedBox(height: 48),
            _buildSignUpFooter(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        Assets.nutrifyLogo,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: NutrifyTheme.background.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: NutrifyTheme.accentOrange, width: 2),
          ),
          child: Icon(
            Icons.pie_chart_outline,
            color: NutrifyTheme.accentOrange,
            size: 50,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Nutrify',
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        color: NutrifyTheme.accentOrange,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Track your calories. Transform your life.',
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildEmailField() {
    return Observer(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _userEmailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  _formStore.setUserId(value);
                },
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Masukkan Email Anda',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              if (_formStore.formErrorStore.userEmail != null)
                Padding(
                  padding: const EdgeInsets.only(left: 48, bottom: 8),
                  child: Text(
                    _formStore.formErrorStore.userEmail!,
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Observer(
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: !_loginPasswordVisible,
                  onChanged: (value) {
                    _formStore.setPassword(value);
                  },
                  style: TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Masukkan password',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.grey[600],
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                        () => _loginPasswordVisible = !_loginPasswordVisible,
                      ),
                      child: Icon(
                        _loginPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[600],
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                if (_formStore.formErrorStore.password != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 48, bottom: 8),
                    child: Text(
                      _formStore.formErrorStore.password!,
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showForgotPasswordDialog(),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: NutrifyTheme.accentOrange,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      height: 60,
      child: ElevatedButton(
        onPressed: () async {
          if (_formStore.canLogin) {
            DeviceUtils.hideKeyboard(context);
            _userStore.login(
              _userEmailController.text,
              _passwordController.text,
            );
          } else {
            _showErrorMessage('Please fill in all fields');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: NutrifyTheme.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          'Login',
          style: TextStyle(
            color: NutrifyTheme.accentOrange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'OR',
            style: TextStyle(
              color: NutrifyTheme.accentOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    void _comingSoon() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Segera hadir 🚀'),
          backgroundColor: NutrifyTheme.darkCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              try {
                await _userStore.signInWithGoogle();
              } catch (e) {
                _showErrorMessage('Login Google gagal: $e');
              }
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: NutrifyTheme.darkCard,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Icon(Icons.g_mobiledata, color: Colors.blue, size: 30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don\u2019t have an account? ",
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => _showSignUpModal(),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: NutrifyTheme.accentOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog<String>(
      context: context,
      builder: (dialogCtx) => _ForgotPasswordDialogContent(
        initialEmail: _userEmailController.text.trim(),
      ),
    ).then((sentEmail) {
      if (sentEmail != null && mounted) {
        FlushbarHelper.createSuccess(
          message: 'Link reset password telah dikirim ke $sentEmail',
          title: 'Email Terkirim!',
          duration: const Duration(seconds: 4),
        ).show(context);
      }
    });
  }

  void _showSignUpModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => _SignUpModalContent(
        initialEmail: _userEmailController.text.trim(),
      ),
    ).then((registered) {
      // Sheet is fully dismissed — safe to show flushbar in parent context
      if ((registered ?? false) && mounted) {
        FlushbarHelper.createSuccess(
          message: 'Akun berhasil dibuat! Cek email Anda untuk konfirmasi.',
          title: 'Berhasil!',
          duration: const Duration(seconds: 4),
        ).show(context);
      }
    });
  }

  void _handleNavigation() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.home, 
      (Route<dynamic> route) => false
    );
  }

  // General Methods:-----------------------------------------------------------

  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      FlushbarHelper.createError(
        message: message,
        title: AppLocalizations.of(context).translate('home_tv_error'),
        duration: Duration(seconds: 3),
      )..show(context);
    }
    return SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Bersihkan semua reaction agar tidak memory leak
    for (var d in _disposers) {
      d();
    }
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODAL COMPONENTS (Managed as separate StatefulWidgets to avoid
// "TextEditingController used after being disposed" errors during transition
// animations)
// ─────────────────────────────────────────────────────────────────────────────

class _ForgotPasswordDialogContent extends StatefulWidget {
  final String initialEmail;
  const _ForgotPasswordDialogContent({required this.initialEmail});

  @override
  State<_ForgotPasswordDialogContent> createState() =>
      _ForgotPasswordDialogContentState();
}

class _ForgotPasswordDialogContentState
    extends State<_ForgotPasswordDialogContent> {
  late final TextEditingController emailCtrl;
  final _userStore = getIt<UserStore>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: NutrifyTheme.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reset Password',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Masukkan email Anda. Kami akan kirim link reset password.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final email = emailCtrl.text.trim();
                          if (email.isEmpty) return;

                          setState(() => isLoading = true);
                          try {
                            await _userStore.forgotPassword(email);
                            if (mounted) {
                              Navigator.pop(context, email);
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => isLoading = false);
                              // Error handling inside dialog
                              FlushbarHelper.createError(
                                message: _parseError(e),
                                title: 'Kesalahan',
                              ).show(context);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NutrifyTheme.accentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Kirim',
                          style: TextStyle(
                            color: NutrifyTheme.darkCard,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _parseError(dynamic e) {
    if (e is sb.AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid_credentials')) {
        return 'Email atau password salah';
      }
      if (msg.contains('email not confirmed')) {
        return 'Cek email Anda untuk konfirmasi akun terlebih dahulu';
      }
      if (msg.contains('user already registered') ||
          msg.contains('already registered')) {
        return 'Email sudah terdaftar, silakan login';
      }
      if (msg.contains('password should be at least') ||
          msg.contains('weak_password')) {
        return 'Password minimal 6 karakter';
      }
      if (msg.contains('unable to validate email')) {
        return 'Format email tidak valid';
      }
      if (msg.contains('rate limit')) {
        return 'Terlalu banyak percobaan. Tunggu sebentar.';
      }
      return e.message.isNotEmpty ? e.message : 'Terjadi kesalahan autentikasi';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}

class _SignUpModalContent extends StatefulWidget {
  final String initialEmail;
  const _SignUpModalContent({required this.initialEmail});

  @override
  State<_SignUpModalContent> createState() => _SignUpModalContentState();
}

class _SignUpModalContentState extends State<_SignUpModalContent> {
  final _userStore = getIt<UserStore>();
  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;
  final passCtrl = TextEditingController();
  bool passVisible = false;
  bool isLoading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          color: Color(0xFF49426E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: Image.asset(
                Assets.makananRegister,
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  color: NutrifyTheme.darkCard,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF35315D).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Nutrify',
                    style: GoogleFonts.montserrat(
                      color: NutrifyTheme.accentOrange,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
              ),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Color(0xFF49426E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        Assets.nutrifyLogo,
                        height: 70,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.pie_chart_outline,
                          color: NutrifyTheme.accentOrange,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nutrify',
                        style: GoogleFonts.montserrat(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: NutrifyTheme.accentOrange,
                        ),
                      ),
                      Text(
                        'Buat Akun Baru',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (errorMsg != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700.withOpacity(
                              0.25,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red.shade300,
                            ),
                          ),
                          child: Text(
                            errorMsg!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      _buildRegisterTextField(
                        controller: nameCtrl,
                        hint: 'Nama lengkap',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                      _buildRegisterTextField(
                        controller: emailCtrl,
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: passCtrl,
                          obscureText: !passVisible,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Password (min. 6 karakter)',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[600],
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                () => passVisible = !passVisible,
                              ),
                              child: Icon(
                                passVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final name = nameCtrl.text.trim();
                                  final email = emailCtrl.text.trim();
                                  final pass = passCtrl.text;
                                  if (name.isEmpty ||
                                      email.isEmpty ||
                                      pass.isEmpty) {
                                    setState(
                                      () => errorMsg =
                                          'Semua field harus diisi',
                                    );
                                    return;
                                  }
                                  if (pass.length < 6) {
                                    setState(
                                      () => errorMsg =
                                          'Password minimal 6 karakter',
                                    );
                                    return;
                                  }
                                  setState(() {
                                    isLoading = true;
                                    errorMsg = null;
                                  });
                                  try {
                                    await _userStore.register(
                                      name,
                                      email,
                                      pass,
                                    );
                                    if (mounted) {
                                      Navigator.pop(context, true);
                                    }
                                  } catch (e) {
                                    setState(() {
                                      errorMsg = _parseError(e);
                                      isLoading = false;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF35315D),
                            disabledBackgroundColor: const Color(
                              0xFF35315D,
                            ).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: NutrifyTheme.accentOrange,
                                  ),
                                )
                              : Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: NutrifyTheme.accentOrange,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Sudah punya akun? Masuk',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  String _parseError(dynamic e) {
    if (e is sb.AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid_credentials')) {
        return 'Email atau password salah';
      }
      if (msg.contains('email not confirmed')) {
        return 'Cek email Anda untuk konfirmasi akun terlebih dahulu';
      }
      if (msg.contains('user already registered') ||
          msg.contains('already registered')) {
        return 'Email sudah terdaftar, silakan login';
      }
      if (msg.contains('password should be at least') ||
          msg.contains('weak_password')) {
        return 'Password minimal 6 karakter';
      }
      if (msg.contains('unable to validate email')) {
        return 'Format email tidak valid';
      }
      if (msg.contains('rate limit')) {
        return 'Terlalu banyak percobaan. Tunggu sebentar.';
      }
      return e.message.isNotEmpty ? e.message : 'Terjadi kesalahan autentikasi';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
