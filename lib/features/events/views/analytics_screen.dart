import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/models.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key, required this.event});

  final OrgEvent event;

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final event = repo.events.firstWhere((e) => e.id == this.event.id, orElse: () => this.event);

    final int total = event.totalInvited;
    final double responseRate = total == 0 ? 0.0 : ((event.acceptedCount + event.declinedCount) / total) * 100;
    final double conversion = total == 0 ? 0.0 : (event.acceptedCount / total) * 100;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Campaign Analytics',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Event Selector Brief Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_outlined, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACTIVE CAMPAIGN',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Wide Response Rate Badge Card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.cta, Color(0xFFF09A72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1CEF8A62),
                      blurRadius: 15,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONVERSION RATIO',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${responseRate.toStringAsFixed(1)}% Response Rate',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Based on $total total invited guest${total == 1 ? "" : "s"}',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.trending_up_rounded, color: Colors.white, size: 36),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. 2x2 Stat Grid (Monospace numbers)
              Row(
                children: [
                  Expanded(child: _buildGridCard('INVITED', '${event.totalInvited}', AppColors.primary)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildGridCard('ACCEPTED', '${event.acceptedCount}', AppColors.success)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildGridCard('PENDING', '${event.pendingCount}', AppColors.pending)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildGridCard('DECLINED', '${event.declinedCount}', AppColors.danger)),
                ],
              ),

              const SizedBox(height: 28),

              // 4. Donut Chart with Center % (Custom Painter)
              const Text(
                'RSVP RATIO DISTRIBUTION',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Donut Painter
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(120, 120),
                            painter: DonutChartPainter(
                              accepted: event.acceptedCount.toDouble(),
                              pending: event.pendingCount.toDouble(),
                              declined: event.declinedCount.toDouble(),
                            ),
                          ),
                          // Center %
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${conversion.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const Text(
                                'CONV.',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Legends
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendRow('Accepted Passes', AppColors.success),
                          const SizedBox(height: 10),
                          _buildLegendRow('Awaiting Handshake', AppColors.pending),
                          const SizedBox(height: 10),
                          _buildLegendRow('Declined Passes', AppColors.danger),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 5. Line Chart: RSVP Timeline (Custom Painter, no gridlines)
              const Text(
                'RSVP TIMELINE DRIFT',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: TimelineLineChartPainter(),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  DonutChartPainter({
    required this.accepted,
    required this.pending,
    required this.declined,
  });

  final double accepted;
  final double pending;
  final double declined;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 14.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth);

    // Draw background track
    final paintTrack = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth, paintTrack);

    final double total = accepted + pending + declined;
    if (total == 0) return;

    final acceptedSweep = (accepted / total) * 2 * 3.14159265;
    final pendingSweep = (pending / total) * 2 * 3.14159265;
    final declinedSweep = (declined / total) * 2 * 3.14159265;

    final paintAccepted = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintPending = Paint()
      ..color = AppColors.pending
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintDeclined = Paint()
      ..color = AppColors.danger
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -3.14159265 / 2; // Start from top

    // Draw Accepted segment
    canvas.drawArc(rect, startAngle, acceptedSweep, false, paintAccepted);
    startAngle += acceptedSweep;

    // Draw Pending segment
    canvas.drawArc(rect, startAngle, pendingSweep, false, paintPending);
    startAngle += pendingSweep;

    // Draw Declined segment
    canvas.drawArc(rect, startAngle, declinedSweep, false, paintDeclined);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TimelineLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.cta // Coral line
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintArea = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.cta.withOpacity(0.15), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    // Timeline drift coordinate paths representing response trajectory
    final path = Path()
      ..moveTo(0, size.height * 0.85)
      ..cubicTo(
        size.width * 0.25, size.height * 0.75,
        size.width * 0.45, size.height * 0.35,
        size.width * 0.65, size.height * 0.2,
      )
      ..lineTo(size.width, size.height * 0.1);

    final areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(areaPath, paintArea);
    canvas.drawPath(path, paintLine);

    // Draw axis line at bottom
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint);

    // Draw nodes / indicator circles
    final nodePaint = Paint()
      ..color = AppColors.cta
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.2), 4, nodePaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.1), 4, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
