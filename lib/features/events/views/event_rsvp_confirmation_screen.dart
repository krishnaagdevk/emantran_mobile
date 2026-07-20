import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../data/models/models.dart';
import '../../dashboard/views/dashboard_screen.dart';

class EventRSVPConfirmationScreen extends StatelessWidget {
  const EventRSVPConfirmationScreen({
    super.key,
    required this.event,
    required this.guestName,
    required this.isAttending,
  });

  final OrgEvent event;
  final String guestName;
  final bool isAttending;

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // 1. Success checkmark / circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isAttending ? AppColors.success : AppColors.danger,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isAttending 
                            ? const Color(0x2510B981) 
                            : const Color(0x25E11D48),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    isAttending ? Icons.check_rounded : Icons.close_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  isAttending ? 'RSVP Confirmed!' : 'Response Logged',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontSize: 26,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAttending 
                      ? 'Thank you, $guestName. Your entry ticket has been dispatched.'
                      : 'We have updated $guestName\'s response status to declined.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                // 2. Ticket Graphic Wrapper (Bento aesthetic)
                if (isAttending)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x041E1B1A),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Ticket block
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: AppColors.muted, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.venue,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, color: AppColors.muted, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${event.dateText} — ${event.timeText}',
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Ticket cutting dashed line
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: List.generate(30, (index) {
                              return Expanded(
                                child: Container(
                                  height: 1.2,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  color: AppColors.faint.withOpacity(0.4),
                                ),
                              );
                            }),
                          ),
                        ),

                        // Bottom Ticket block: Monospace Ticket Code & QR placeholder
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              // Left: Ticket Number
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PASS REGISTERED TO:',
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.muted.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      guestName.toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'TICKET NUMBER:',
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.muted.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'EMT-9921-ADOB',
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(width: 14),
                              
                              // Right: Geometric QR code placeholder
                              Container(
                                width: 74,
                                height: 74,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border, width: 1.2),
                                  color: AppColors.surface,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: CustomPaint(
                                  painter: GeometricQRCodePainter(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 48),

                // Button: Go to Room
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Go to room'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw a sleek, highly-stylized geometric vector QR code outline
class GeometricQRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    // Draw standard corner anchors representing a real QR scanner target
    final boxSize = 14.0;
    
    // Top-Left
    canvas.drawRect(Rect.fromLTWH(0, 0, boxSize, boxSize), paint);
    canvas.drawRect(Rect.fromLTWH(2, 2, boxSize - 4, boxSize - 4), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(4, 4, boxSize - 8, boxSize - 8), paint);

    // Top-Right
    canvas.drawRect(Rect.fromLTWH(size.width - boxSize, 0, boxSize, boxSize), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - boxSize + 2, 2, boxSize - 4, boxSize - 4), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width - boxSize + 4, 4, boxSize - 8, boxSize - 8), paint);

    // Bottom-Left
    canvas.drawRect(Rect.fromLTWH(0, size.height - boxSize, boxSize, boxSize), paint);
    canvas.drawRect(Rect.fromLTWH(2, size.height - boxSize + 2, boxSize - 4, boxSize - 4), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(4, size.height - boxSize + 4, boxSize - 8, boxSize - 8), paint);

    // Draw some random geometric code dot patterns inside
    final dotsPaint = Paint()..color = AppColors.cta;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.4, size.height * 0.4, 8, 8), dotsPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, size.height * 0.5, 6, 6), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.7, 8, 4), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.65, size.height * 0.25, 4, 10), dotsPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.15, size.height * 0.4, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.75, size.height * 0.75, 10, 10), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
