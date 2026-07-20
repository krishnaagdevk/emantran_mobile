import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../dashboard/views/dashboard_screen.dart';

class Error404Screen extends StatelessWidget {
  const Error404Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return AtmosphericBlobs(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Broken Envelope Vector Illustration
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 140,
                    child: CustomPaint(
                      painter: BrokenEnvelopePainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // 2. 404 Heading (Monospace)
                const Text(
                  '404',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Subtext
                const Text(
                  'Nothing here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The room partition has been deleted, or this invitation link has expired.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 48),

                // 4. Primary CTA: Go to Dashboard (220px wide or stretched with centering)
                Center(
                  child: SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('Go to dashboard'),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 5. Ghost CTA: Contact support
                Center(
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support ticket dispatched automatically.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        color: AppColors.violet,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter to render a gorgeous premium broken envelope graphic vector representation
class BrokenEnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final crackPaint = Paint()
      ..color = AppColors.danger // Red crack lines
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw main envelope body rectangles (Left block & Right block representing split/broken envelope!)
    final leftBody = Path()
      ..moveTo(10, size.height * 0.2)
      ..lineTo(size.width * 0.45, size.height * 0.2)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(10, size.height * 0.8)
      ..close();

    final rightBody = Path()
      ..moveTo(size.width * 0.55, size.height * 0.25)
      ..lineTo(size.width - 10, size.height * 0.25)
      ..lineTo(size.width - 10, size.height * 0.85)
      ..lineTo(size.width * 0.6, size.height * 0.85)
      ..close();

    canvas.drawPath(leftBody, borderPaint);
    canvas.drawPath(rightBody, borderPaint);

    // Draw flap lines
    final leftFlap = Path()
      ..moveTo(10, size.height * 0.2)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.2);
    canvas.drawPath(leftFlap, borderPaint);

    final rightFlap = Path()
      ..moveTo(size.width * 0.55, size.height * 0.25)
      ..lineTo(size.width * 0.75, size.height * 0.55)
      ..lineTo(size.width - 10, size.height * 0.25);
    canvas.drawPath(rightFlap, borderPaint);

    // Draw some bold digital zig-zag red crack lines in between
    final crackPath = Path()
      ..moveTo(size.width * 0.44, size.height * 0.15)
      ..lineTo(size.width * 0.52, size.height * 0.4)
      ..lineTo(size.width * 0.46, size.height * 0.6)
      ..lineTo(size.width * 0.55, size.height * 0.9);
    canvas.drawPath(crackPath, crackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
