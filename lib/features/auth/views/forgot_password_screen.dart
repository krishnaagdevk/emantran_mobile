import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../app/widgets/frameless_text_field.dart';
import '../../../data/repositories/api_repository.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitted = false;
  bool _isLoading = false;

  // Resend Link Debounce Timer
  Timer? _debounceTimer;
  int _secondsRemaining = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _startResendDebounce() {
    setState(() {
      _secondsRemaining = 30;
    });
    _debounceTimer?.cancel();
    _debounceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendResetLink() async {
    if (_isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final repo = Provider.of<ApiRepository>(context, listen: false);
        await repo.sendForgotPasswordLink(_emailController.text.trim());
        
        setState(() {
          _isSubmitted = true;
          _isLoading = false;
        });
        _startResendDebounce();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
                ],
              ),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0 || _isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final repo = Provider.of<ApiRepository>(context, listen: false);
      await repo.sendForgotPasswordLink(_emailController.text.trim());
      setState(() {
        _isLoading = false;
      });
      _startResendDebounce();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification link resent successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AtmosphericBlobs(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 350),
              crossFadeState: _isSubmitted 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
              firstChild: _buildInputState(),
              secondChild: _buildSuccessState(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputState() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0x0F372475),
                shape: BoxShape.circle,
              ),
              child: CustomPaint(
                painter: EnvelopeTrajectoryPainter(),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Reset your password',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontSize: 28,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Enter your organization email below and we will dispatch a secure validation link.',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: AppColors.muted,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x061E1B1A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FramelessTextField(
                    labelText: 'organization email',
                    hintText: 'sarah.jenkins@adobe.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!emailRegex.hasMatch(val.trim())) {
                        return 'Please enter a valid email format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    child: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Send reset link'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x3010B981),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Check your inbox',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontSize: 28,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'We have successfully sent a secure reset link to ${_emailController.text}. Please check your spam folder if you do not receive it in a few minutes.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.muted,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),

        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(email: _emailController.text.trim()),
              ),
            );
          },
          child: const Text('Open Set New Password'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _secondsRemaining > 0 || _isLoading ? null : _handleResend,
          child: Text(
            _secondsRemaining > 0 
                ? 'Resend link in (${_secondsRemaining}s)' 
                : 'Resend link',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: _secondsRemaining > 0 ? AppColors.faint : AppColors.violet,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class EnvelopeTrajectoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violet
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.7)
      ..cubicTo(
        size.width * 0.35, size.height * 0.2,
        size.width * 0.65, size.height * 0.2,
        size.width * 0.8, size.height * 0.5,
      );

    canvas.drawPath(path, paint);

    final envPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width * 0.8, size.height * 0.5),
      width: 32,
      height: 22,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas.drawRRect(rrect, envPaint);

    final flap = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.center.dx, rect.center.dy + 2)
      ..lineTo(rect.right, rect.top);
    canvas.drawPath(flap, envPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
