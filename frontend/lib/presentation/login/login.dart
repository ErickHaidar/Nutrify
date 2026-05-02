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
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:nutrify/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart' as mobx;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:nutrify/screens/otp_verification_screen.dart';

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
      body: SafeArea(
        child: _buildBody(),
      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Spacer(flex: 2),
                    _buildLogo(),
                    const SizedBox(height: 12),
                    _buildTitle(),
                    const SizedBox(height: 4),
                    _buildSubtitle(),
                    const SizedBox(height: 32),
                    Spacer(flex: 2),
                    _buildEmailField(),
                    const SizedBox(height: 12),
                    _buildPasswordField(),
                    _buildForgotPasswordButton(),
                    const SizedBox(height: 12),
                    _buildSignInButton(),
                    const SizedBox(height: 24),
                    _buildOrDivider(),
                    const SizedBox(height: 24),
                    _buildSocialButtons(),
                    const SizedBox(height: 32),
                    Spacer(flex: 4),
                    _buildSignUpFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
            color: NutrifyTheme.darkCard.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: NutrifyTheme.darkCard, width: 2),
          ),
          child: const Icon(
            Icons.pie_chart_outline,
            color: NutrifyTheme.darkCard,
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
      style: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: const Color(0xFFFFB26B),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      AppStrings.loginSubtitle,
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: NutrifyTheme.darkCard,
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
            border: _formStore.formErrorStore.userEmail != null
                ? Border.all(color: Colors.red, width: 1.5)
                : null,
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
                  hintText: AppStrings.enterEmail,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              if (_formStore.formErrorStore.userEmail != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _formStore.formErrorStore.userEmail!,
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
              border: _formStore.formErrorStore.password != null
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
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
                    hintText: AppStrings.enterPassword,
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.grey[500],
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                        () => _loginPasswordVisible = !_loginPasswordVisible,
                      ),
                      child: Icon(
                        _loginPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[500],
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                if (_formStore.formErrorStore.password != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _formStore.formErrorStore.password!,
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
          AppStrings.forgotPassword,
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
            _showErrorMessage(AppStrings.fillAllFields);
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
          'Masuk',
          style: TextStyle(
            color: Colors.white,
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
        Expanded(child: Divider(color: NutrifyTheme.darkCard.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'ATAU',
            style: TextStyle(
              color: NutrifyTheme.accentOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: NutrifyTheme.darkCard.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    void _comingSoon() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.comingSoon),
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
                _showErrorMessage('${AppStrings.googleLoginFailed}: $e');
              }
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(Assets.iconGoogle, height: 24),
                  const SizedBox(width: 12),
                  Text(
                    "${AppStrings.signInWithGoogle}",
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
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
          text: AppStrings.dontHaveAccount,
          style: TextStyle(color: NutrifyTheme.darkCard, fontSize: 14),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => _showSignUpModal(),
                child: Text(
                  AppStrings.signUp,
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
        _showCheckEmailModal(sentEmail);
      }
    });
  }

  void _showCheckEmailModal(String sentEmail) {
    showDialog(
      context: context,
      builder: (context) => _CheckEmailModalContent(email: sentEmail),
    );
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
          message: AppStrings.accountCreated,
          title: AppStrings.success,
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: NutrifyTheme.lightCard,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.priority_high, color: NutrifyTheme.darkCard, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.loginFailed,
                style: GoogleFonts.montserrat(
                  color: NutrifyTheme.darkCard,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: NutrifyTheme.darkCard),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NutrifyTheme.darkCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text(AppStrings.close, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
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
              AppStrings.resetPassword,
              style: GoogleFonts.montserrat(
                color: NutrifyTheme.darkCard,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.resetPasswordDesc,
              style: TextStyle(color: NutrifyTheme.darkCard.withOpacity(0.8), fontSize: 13),
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
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppStrings.cancel, style: const TextStyle(color: NutrifyTheme.darkCard, fontWeight: FontWeight.w600)),
                  ),
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
                                title: AppStrings.error,
                              ).show(context);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NutrifyTheme.darkCard,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                          AppStrings.send,
                          style: TextStyle(
                            color: Colors.white,
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
          color: NutrifyTheme.background,
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
                    color: NutrifyTheme.background.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Nutrify',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFB26B),
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
                  color: NutrifyTheme.background,
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
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.pie_chart_outline,
                          color: NutrifyTheme.accentOrange,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nutrify',
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFB26B),
                        ),
                      ),
                      Text(
                        AppStrings.createNewAccount,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: NutrifyTheme.darkCard,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppStrings.fullName,
                          style: TextStyle(
                            color: NutrifyTheme.darkCard,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRegisterTextField(
                        controller: nameCtrl,
                        hint: AppStrings.fullNameHint,
                        icon: Icons.person_outline,
                        hasError: errorMsg != null && (errorMsg!.contains('Nama') || errorMsg!.contains('Semua')),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppStrings.emailLabel,
                          style: TextStyle(
                            color: NutrifyTheme.darkCard,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRegisterTextField(
                        controller: emailCtrl,
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        hasError: errorMsg != null && (errorMsg!.contains('Email') || errorMsg!.contains('Semua')),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppStrings.passwordLabel,
                          style: TextStyle(
                            color: NutrifyTheme.darkCard,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: errorMsg != null && (errorMsg!.contains('Password') || errorMsg!.contains('kata sandi') || errorMsg!.contains('Semua'))
                              ? Border.all(color: Colors.red, width: 1.5)
                              : null,
                        ),
                        child: TextField(
                          controller: passCtrl,
                          obscureText: !passVisible,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: AppStrings.passwordHint,
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => passVisible = !passVisible),
                              child: Icon(
                                passVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[500],
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      if (errorMsg != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  errorMsg!,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
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
                                      () => errorMsg = AppStrings.allFieldsRequired,
                                    );
                                    return;
                                  }
                                  if (!email.toLowerCase().endsWith('@gmail.com')) {
                                    setState(
                                      () => errorMsg = AppStrings.onlyGmail,
                                    );
                                    return;
                                  }
                                  if (pass.length < 6) {
                                    setState(
                                      () => errorMsg = AppStrings.passwordMinLength,
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
                                      Navigator.pop(context); // Close signup modal
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OtpVerificationScreen(email: email),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      errorMsg = _parseError(e);
                                      isLoading = false;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NutrifyTheme.darkCard,
                            disabledBackgroundColor: const Color(
                              0xFF322E53,
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
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    color: Colors.white,
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
                          AppStrings.alreadyHaveAccount,
                          style: TextStyle(
                            color: NutrifyTheme.darkCard.withOpacity(0.7),
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
    bool hasError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
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
        return AppStrings.wrongCredentials;
      }
      if (msg.contains('email not confirmed')) {
        return AppStrings.confirmEmailFirst;
      }
      if (msg.contains('user already registered') ||
          msg.contains('already registered')) {
        return AppStrings.emailAlreadyRegistered;
      }
      if (msg.contains('password should be at least') ||
          msg.contains('weak_password')) {
        return AppStrings.passwordMinLength;
      }
      if (msg.contains('unable to validate email')) {
        return AppStrings.invalidEmail;
      }
      if (msg.contains('rate limit')) {
        return AppStrings.tooManyAttempts;
      }
      return e.message.isNotEmpty ? e.message : AppStrings.authError;
    }
    return AppStrings.generalError;
  }
}
class _CheckEmailModalContent extends StatelessWidget {
  final String email;
  final UserStore _userStore = getIt<UserStore>();

  _CheckEmailModalContent({required this.email});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: NutrifyTheme.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read,
                    color: NutrifyTheme.darkCard,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.checkYourEmail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: NutrifyTheme.darkCard,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.clickVerificationLink,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: NutrifyTheme.darkCard,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 32),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: NutrifyTheme.darkCard,
                    ),
                    children: [
                      const TextSpan(text: "Tidak menerima email? "),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () {
                            _userStore.forgotPassword(email);
                            FlushbarHelper.createSuccess(
                              message: AppStrings.emailResent,
                              title: AppStrings.success,
                              duration: const Duration(seconds: 3),
                            ).show(context);
                          },
                          child: Text(
                              AppStrings.resend,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: NutrifyTheme.darkCard,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: NutrifyTheme.darkCard),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

