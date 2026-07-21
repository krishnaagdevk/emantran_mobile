import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';
import 'event_rsvp_list_screen.dart';
import 'event_invite_screen.dart';
import 'analytics_screen.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final OrgEvent event;

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final event = repo.events.firstWhere((e) => e.id == this.event.id, orElse: () => this.event);
    final isLive = event.isLive;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image Banner with Back overlays
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(event.bannerUrl ?? 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=600'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Soft gradient on bottom of image for readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Floating top buttons
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border_rounded, color: AppColors.primary, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),

            // 2. Event Core Details Card
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live Now indicator
                  if (isLive)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cta.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sensors, color: AppColors.cta, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'LIVE METRICS STREAMING',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: AppColors.cta,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 26,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 18),

                  // Host Info block
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withOpacity(0.08),
                        child: Text(
                          event.hostName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hosted by'.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            event.hostName,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.border),
                  ),

                  // Time and location parameters
                  _buildDetailMetaRow(Icons.calendar_today_outlined, 'Date', '${event.dateText} — ${event.timeText}'),
                  const SizedBox(height: 14),
                  _buildDetailMetaRow(Icons.location_on_outlined, 'Venue', event.venue),
                  const SizedBox(height: 14),
                  _buildDetailMetaRow(
                    Icons.payments_outlined, 
                    'Ticket Cost', 
                    event.isFree ? 'Free Admission' : '\$${event.price.toStringAsFixed(2)}',
                    textColor: event.isFree ? AppColors.success : AppColors.violet,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.border),
                  ),

                  // RSVP Metrics Block (Tapping navigates to RSVP list)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventRSVPListScreen(event: event),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1.2),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'INVITATION STATS',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted.withOpacity(0.8),
                                ),
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Guest List',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.violet,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, color: AppColors.violet, size: 10),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildRSVPMetric(event.acceptedCount, 'ACCEPTED', AppColors.success),
                              _buildRSVPMetric(event.pendingCount, 'PENDING', AppColors.pending),
                              _buildRSVPMetric(event.declinedCount, 'DECLINED', AppColors.danger),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Mini segmented visual ratio bar
                          _buildSegmentedBar(event),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description notes title
                  const Text(
                    'EVENT OVERVIEW',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.notes,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Invite Guests CTA Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventInviteScreen(event: event),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Invite guests'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnalyticsScreen(event: event),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.violet, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_rounded, color: AppColors.violet, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'View Campaign Analytics',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: AppColors.violet,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailMetaRow(IconData icon, String label, String value, {Color? textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRSVPMetric(int count, String label, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedBar(OrgEvent event) {
    final total = event.totalInvited;
    if (total == 0) return const SizedBox();

    final accPct = event.acceptedCount / total;
    final pendPct = event.pendingCount / total;
    final decPct = event.declinedCount / total;

    return Container(
      height: 6,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          if (accPct > 0)
            Expanded(
              flex: (accPct * 100).round(),
              child: Container(color: AppColors.success),
            ),
          if (pendPct > 0)
            Expanded(
              flex: (pendPct * 100).round(),
              child: Container(color: AppColors.pending),
            ),
          if (decPct > 0)
            Expanded(
              flex: (decPct * 100).round(),
              child: Container(color: AppColors.danger),
            ),
        ],
      ),
    );
  }
}
