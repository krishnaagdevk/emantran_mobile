import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../app/widgets/frameless_text_field.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitted = true;
      });
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Envelope trajectory geometric art / icon
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
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

          // Email form card
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
                      if (val == null || val.trim().isEmpty || !val.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _sendResetLink,
                    child: const Text('Send reset link'),
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
        // Big green success tick / envelope circle
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
          'We have successfully sent a secure reset link to ${_emailController.text}. Please check your folder spam if you do not receive it in a few minutes.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.muted,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),

        // Action Options
        ElevatedButton(
          onPressed: () {
            // Direct simulator shortcut for testing: reset password
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
            );
          },
          child: const Text('Open Set New Password'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _isSubmitted = false;
            });
          },
          child: const Text(
            'Resend link',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: AppColors.violet,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter to draw a minimalist envelope trajectory curve
class EnvelopeTrajectoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violet
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = AppColors.faint
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.7)
      ..cubicTo(
        size.width * 0.35, size.height * 0.2,
        size.width * 0.65, size.height * 0.2,
        size.width * 0.8, size.height * 0.5,
      );

    // Draw solid path
    canvas.drawPath(path, paint);

    // Draw solid envelope outline
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

    // draw flap
    final flap = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.center.dx, rect.center.dy + 2)
      ..lineTo(rect.right, rect.top);
    canvas.drawPath(flap, envPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
