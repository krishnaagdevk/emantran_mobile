import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();

    // Transition after animation finishes
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stunning Custom Brand Mark
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F18181B), // very subtle shadow
                            blurRadius: 30,
                            offset: Offset(0, 12),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: CustomPaint(
                          painter: BrandMarkPainter(progress: _controller.value),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            // Brand Wordmark
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _textFadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'Emantran',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          letterSpacing: -1.2,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ELEGANT RSVP & INVITATIONS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BrandMarkPainter extends CustomPainter {
  final double progress;

  BrandMarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Draw an elegant physical envelope outline transitioning into an 'E' monogram
    // Line 1: Envelope top fold / 'E' horizontal top line
    path.moveTo(size.width * 0.2, size.height * 0.25);
    path.lineTo(size.width * 0.8, size.height * 0.25);

    // Line 2: Envelope side / 'E' vertical spine
    path.moveTo(size.width * 0.25, size.height * 0.25);
    path.lineTo(size.width * 0.25, size.height * 0.75);

    // Line 3: 'E' horizontal middle line / inner card line
    if (progress > 0.4) {
      double midProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
      path.moveTo(size.width * 0.25, size.height * 0.5);
      path.lineTo(size.width * 0.25 + (size.width * 0.45 * midProgress), size.height * 0.5);
    }

    // Line 4: Envelope bottom fold / 'E' horizontal bottom line
    path.moveTo(size.width * 0.2, size.height * 0.75);
    path.lineTo(size.width * 0.8, size.height * 0.75);

    // Beautiful envelope V-fold diagonal lines that form a subtle geometric overlap
    if (progress > 0.3) {
      double foldProgress = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
      path.moveTo(size.width * 0.25, size.height * 0.25);
      path.lineTo(
        size.width * 0.25 + (size.width * 0.25 * foldProgress),
        size.height * 0.25 + (size.height * 0.20 * foldProgress),
      );
      path.moveTo(size.width * 0.75, size.height * 0.25);
      path.lineTo(
        size.width * 0.75 - (size.width * 0.25 * foldProgress),
        size.height * 0.25 + (size.height * 0.20 * foldProgress),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BrandMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
