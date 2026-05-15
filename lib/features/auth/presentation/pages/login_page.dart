import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../providers/auth_provider.dart';

// ── Design tokens (mirrors login.html color palette) ─────────────────────────
const _bg = Color(0xFFF9F9FF);
const _primary = Color(0xFF005BBF);
const _primaryContainer = Color(0xFF1A73E8);
const _surfaceTint = Color(0xFF005BC0);
const _surfaceContainerHighest = Color(0xFFE0E2EC);
const _onBackground = Color(0xFF191C23);
const _onSurfaceVariant = Color(0xFF414754);
const _outline = Color(0xFF727785);
const _outlineVariant = Color(0xFFC1C6D6);
const _secondaryContainer = Color(0xFF68FADD);
const _errorColor = Color(0xFFBA1A1A);
const _errorContainer = Color(0xFFFFDAD6);
const _onErrorContainer = Color(0xFF93000A);

// ── Page ──────────────────────────────────────────────────────────────────────

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authNotifierProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) context.go(AppRoutes.home);
    } on ValidationException catch (e) {
      setState(() => _errorMessage = e.message);
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      if (mounted) context.go(AppRoutes.home);
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Ambient glow — top left (blue)
          const _AmbientGlow(
            alignment: Alignment.topLeft,
            color: Color(0x4DADC7FF),
          ),
          // Ambient glow — bottom right (purple)
          const _AmbientGlow(
            alignment: Alignment.bottomRight,
            color: Color(0x33CDBDFF),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        const _OrbHeader(),
                        const SizedBox(height: 32),
                        if (_errorMessage != null) ...[
                          _ErrorBanner(message: _errorMessage!),
                          const SizedBox(height: 16),
                        ],
                        // Email field
                        _FloatingLabelField(
                          controller: _emailController,
                          label: 'Email hoặc số điện thoại',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password field
                        _FloatingLabelField(
                          controller: _passwordController,
                          label: 'Mật khẩu',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          suffix: GestureDetector(
                            onTap: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _onSurfaceVariant,
                              size: 22,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (v.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => _showForgotPassword(context),
                            child: Text(
                              'Quên mật khẩu?',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: _primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Primary CTA
                        _GradientButton(
                          label: 'Đăng nhập',
                          isLoading: _isLoading,
                          onTap: _submit,
                        ),
                        const SizedBox(height: 16),
                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Chưa có tài khoản?',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 15,
                                color: _onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.register),
                              child: Text(
                                'Đăng ký tài khoản mới',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const _OrDivider(),
                        const SizedBox(height: 24),
                        // Social buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialButton(
                              onTap: _signInWithGoogle,
                              isLoading: _isGoogleLoading,
                              child: const _GoogleLogoIcon(),
                            ),
                            const SizedBox(width: 16),
                            _SocialButton(
                              onTap: () {},
                              child: const _AppleLogoIcon(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quên mật khẩu?'),
        content: TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Nhập email của bạn',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (emailCtrl.text.trim().isEmpty) return;
              await ref
                  .read(authRepositoryProvider)
                  .sendPasswordReset(emailCtrl.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi email đặt lại mật khẩu'),
                  ),
                );
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.alignment,
    required this.color,
  });

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final glowSize = screenW * 0.7;
    final offset = glowSize * 0.25;

    return Positioned(
      left: alignment == Alignment.topLeft ? -offset : null,
      top: alignment == Alignment.topLeft ? -offset : null,
      right: alignment == Alignment.bottomRight ? -offset : null,
      bottom: alignment == Alignment.bottomRight ? -offset : null,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(
            width: glowSize,
            height: glowSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbHeader extends StatelessWidget {
  const _OrbHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AI Orb
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primary, _secondaryContainer],
            ),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.4),
                blurRadius: 30,
              ),
            ],
          ),
          child: Stack(
            children: [
              // White shimmer overlay
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              // Inner gradient ring
              Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [_primary, _primaryContainer],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Chào mừng trở lại',
          style: GoogleFonts.beVietnamPro(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.56,
            color: _onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Đăng nhập để bắt đầu trò chuyện\nvới trợ lý thông minh của bạn.',
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(
            fontSize: 15,
            height: 1.47,
            color: _onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FloatingLabelField extends StatefulWidget {
  const _FloatingLabelField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;

  @override
  State<_FloatingLabelField> createState() => _FloatingLabelFieldState();
}

class _FloatingLabelFieldState extends State<_FloatingLabelField> {
  final _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator,
        style: GoogleFonts.beVietnamPro(
          fontSize: 16,
          height: 1.5,
          color: _onBackground,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: GoogleFonts.beVietnamPro(
            fontSize: 16,
            color: _onSurfaceVariant,
          ),
          floatingLabelStyle: GoogleFonts.beVietnamPro(
            fontSize: 13,
            color: _hasFocus ? _primary : _onSurfaceVariant,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: _hasFocus ? Colors.white : _surfaceContainerHighest,
          contentPadding:
              const EdgeInsets.fromLTRB(16, 22, 16, 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _errorColor, width: 1.5),
          ),
          suffixIcon: widget.suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: widget.suffix,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primary, _surfaceTint],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: isLoading ? null : onTap,
            splashColor: Colors.white.withValues(alpha: 0.2),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: _outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hoặc đăng nhập bằng',
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              color: _outline,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: _outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.child,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isLoading ? null : onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _primary,
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoIcon extends StatelessWidget {
  const _GoogleLogoIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = Paint()..style = PaintingStyle.fill;

    p.color = const Color(0xFF4285F4);
    canvas.drawPath(
      Path()
        ..moveTo(22.56 * s, 12.25 * s)
        ..cubicTo(22.56 * s, 11.47 * s, 22.49 * s, 10.72 * s, 22.36 * s, 10 * s)
        ..lineTo(12 * s, 10 * s)
        ..lineTo(12 * s, 14.26 * s)
        ..lineTo(17.92 * s, 14.26 * s)
        ..cubicTo(17.66 * s, 15.63 * s, 16.88 * s, 16.78 * s, 15.71 * s, 17.56 * s)
        ..lineTo(19.28 * s, 20.33 * s)
        ..cubicTo(21.36 * s, 18.41 * s, 22.56 * s, 15.6 * s, 22.56 * s, 12.25 * s)
        ..close(),
      p,
    );

    p.color = const Color(0xFF34A853);
    canvas.drawPath(
      Path()
        ..moveTo(12 * s, 23 * s)
        ..cubicTo(14.97 * s, 23 * s, 17.46 * s, 22.02 * s, 19.28 * s, 20.33 * s)
        ..lineTo(15.71 * s, 17.56 * s)
        ..cubicTo(14.73 * s, 18.22 * s, 13.48 * s, 18.61 * s, 12 * s, 18.61 * s)
        ..cubicTo(9.13 * s, 18.61 * s, 6.68 * s, 16.68 * s, 5.79 * s, 14.07 * s)
        ..lineTo(2.1 * s, 14.07 * s)
        ..lineTo(2.1 * s, 16.92 * s)
        ..cubicTo(3.93 * s, 20.56 * s, 7.69 * s, 23 * s, 12 * s, 23 * s)
        ..close(),
      p,
    );

    p.color = const Color(0xFFFBBC05);
    canvas.drawPath(
      Path()
        ..moveTo(5.79 * s, 14.07 * s)
        ..cubicTo(5.56 * s, 13.39 * s, 5.43 * s, 12.7 * s, 5.43 * s, 12 * s)
        ..cubicTo(5.43 * s, 11.3 * s, 5.56 * s, 10.61 * s, 5.79 * s, 9.93 * s)
        ..lineTo(5.79 * s, 7.08 * s)
        ..lineTo(2.1 * s, 7.08 * s)
        ..cubicTo(1.33 * s, 8.62 * s, 0.89 * s, 10.27 * s, 0.89 * s, 12 * s)
        ..cubicTo(0.89 * s, 13.73 * s, 1.33 * s, 15.38 * s, 2.1 * s, 16.92 * s)
        ..lineTo(5.79 * s, 14.07 * s)
        ..close(),
      p,
    );

    p.color = const Color(0xFFEA4335);
    canvas.drawPath(
      Path()
        ..moveTo(12 * s, 5.38 * s)
        ..cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s, 16.2 * s, 7.02 * s)
        ..lineTo(19.36 * s, 3.86 * s)
        ..cubicTo(17.45 * s, 2.08 * s, 14.97 * s, 1 * s, 12 * s, 1 * s)
        ..cubicTo(7.69 * s, 1 * s, 3.93 * s, 3.44 * s, 2.1 * s, 7.08 * s)
        ..lineTo(5.79 * s, 9.93 * s)
        ..cubicTo(6.68 * s, 7.32 * s, 9.13 * s, 5.38 * s, 12 * s, 5.38 * s)
        ..close(),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AppleLogoIcon extends StatelessWidget {
  const _AppleLogoIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _ApplePainter()),
    );
  }
}

class _ApplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = _onBackground
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(16.3653 * s, 10.5188 * s)
        ..cubicTo(16.3458 * s, 8.01639 * s, 18.4239 * s, 6.8041 * s, 18.5283 * s, 6.74104 * s)
        ..cubicTo(17.3621 * s, 5.03362 * s, 15.5262 * s, 4.77353 * s, 14.9082 * s, 4.74315 * s)
        ..cubicTo(13.3854 * s, 4.58844 * s, 11.9056 * s, 5.64161 * s, 11.127 * s, 5.64161 * s)
        ..cubicTo(10.3444 * s, 5.64161 * s, 9.12301 * s, 4.76451 * s, 7.8488 * s, 4.79383 * s)
        ..cubicTo(6.18664 * s, 4.81977 * s, 4.6366 * s, 5.75945 * s, 3.78453 * s, 7.24357 * s)
        ..cubicTo(2.04631 * s, 10.2642 * s, 3.33618 * s, 14.7335 * s, 5.03964 * s, 17.1856 * s)
        ..cubicTo(5.87532 * s, 18.3846 * s, 6.86221 * s, 19.7423 * s, 8.16335 * s, 19.6896 * s)
        ..cubicTo(9.42065 * s, 19.6385 * s, 9.90488 * s, 18.8783 * s, 11.4285 * s, 18.8783 * s)
        ..cubicTo(12.952 * s, 18.8783 * s, 13.3916 * s, 19.6896 * s, 14.7077 * s, 19.6644 * s)
        ..cubicTo(16.0664 * s, 19.6385 * s, 16.9205 * s, 18.4357 * s, 17.7512 * s, 17.2343 * s)
        ..cubicTo(18.7214 * s, 15.8157 * s, 19.1179 * s, 14.4377 * s, 19.1415 * s, 14.3644 * s)
        ..cubicTo(19.1102 * s, 14.3512 * s, 16.3888 * s, 13.327 * s, 16.3653 * s, 10.5188 * s)
        ..close()
        ..moveTo(13.8824 * s, 3.0113 * s)
        ..cubicTo(14.5768 * s, 2.1691 * s, 15.0453 * s, 0.999885 * s, 14.9179 * s, 0)
        ..cubicTo(13.8967 * s, 0.0416955 * s, 12.6375 * s, 0.682662 * s, 11.9161 * s, 1.51264 * s)
        ..cubicTo(11.2678 * s, 2.25301 * s, 10.7027 * s, 3.44754 * s, 10.8543 * s, 4.59477 * s)
        ..cubicTo(11.9961 * s, 4.68341 * s, 13.1879 * s, 4.05374 * s, 13.8824 * s, 3.0113 * s)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _errorColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.beVietnamPro(
                fontSize: 15,
                color: _onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
