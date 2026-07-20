import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OverlappingBentoCard extends StatelessWidget {
  const OverlappingBentoCard({
    super.key,
    required this.overlapContent,
    this.headerArt,
    this.cardHeight = 240,
    this.overlapAmount = 24,
    this.tagText,
    this.badgeText,
  });

  final Widget overlapContent;
  final Widget? headerArt;
  final double cardHeight;
  final double overlapAmount;
  final String? tagText;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight + overlapAmount,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Deep Purple Header Container
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: cardHeight,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary, // #372475
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A1E1B1A),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Vector celebration background lines
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CelebrationArtPainter(),
                    ),
                  ),
                  // If explicit art widget is passed
                  if (headerArt != null) Positioned.fill(child: headerArt!),
                  
                  // Optional tag (e.g. "LIVE NOW" / "UPCOMING")
                  if (tagText != null)
                    Positioned(
                      top: 14,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cta,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tagText!.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),

                  // Optional badge (e.g. date)
                  if (badgeText != null)
                    Positioned(
                      top: 14,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // 2. Overlapping White Card (Floating panel)
          Positioned(
            bottom: 0,
            left: 16,
            right: 16,
            height: (cardHeight * 0.4) + overlapAmount,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x121E1B1A),
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: overlapContent,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw elegant geometric vector celebration lines inside the bento deck
class CelebrationArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Elegant soft gradient inside
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      colors: [
        AppColors.primary,
        AppColors.primary.withRed(70).withBlue(150), // slightly lighter violet-purple towards bottom-right
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final bgPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final coralAccentPaint = Paint()
      ..color = AppColors.cta.withOpacity(0.12)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final violetAccentPaint = Paint()
      ..color = AppColors.violet.withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    // Draw some neat concentric geometric circles representing soundwaves/celebration rings
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 40, linePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 80, linePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 120, linePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 160, linePaint);

    // Draw secondary crossing loops
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 60, linePaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 100, linePaint);

    // Draw soft accent shapes
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * -0.1)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.3,
        size.width * 0.9,
        size.height * -0.2,
      );
    canvas.drawPath(path, coralAccentPaint);

    // Dynamic modern celebration rays
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.15),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.25),
      Offset(size.width * 0.55, size.height * 0.22),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.43, size.height * 0.28),
      Offset(size.width * 0.5, size.height * 0.32),
      linePaint,
    );

    // Soft colored geometric circles
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.15), 12, violetAccentPaint);
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.7), 
      18, 
      Paint()..color = AppColors.cta.withOpacity(0.08)..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
