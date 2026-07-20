import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';
import '../../dashboard/views/dashboard_screen.dart';
import 'organization_setup_screen.dart';

class RoomDiscoveryScreen extends StatefulWidget {
  const RoomDiscoveryScreen({super.key});

  @override
  State<RoomDiscoveryScreen> createState() => _RoomDiscoveryScreenState();
}

class _RoomDiscoveryScreenState extends State<RoomDiscoveryScreen> {
  final Set<String> _joinedRoomIds = {}; 

  void _onRoomPressed(OrgRoom room) {
    final repo = Provider.of<ApiRepository>(context, listen: false);
    repo.selectRoom(room);
    
    setState(() {
      _joinedRoomIds.add(room.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to room "${room.name}"'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );

    // Direct transition to the App Dashboard (which is our main tab shell)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final domain = repo.currentUser?.domain ?? 'emantra.app';
    final rooms = repo.availableRooms.where((r) => r.domain.toLowerCase() == domain.toLowerCase()).toList();

    return AtmosphericBlobs(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Find your room',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Available spaces matching your email domain: @$domain',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 28),

                // Rooms List
                Expanded(
                  child: rooms.isEmpty
                      ? const Center(
                          child: Text(
                            'No workspace rooms active on this domain. Create the first one!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Outfit', color: AppColors.muted),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: rooms.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final isJoined = _joinedRoomIds.contains(room.id);

                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border, width: 1.2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x041E1B1A),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  // Logo / Initial circle
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      room.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        color: AppColors.primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Middle Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          room.name,
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (room.isVerified)
                                          // Green verified badge
                                          Row(
                                            children: [
                                              const Icon(Icons.verified, color: AppColors.success, size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Verified Room'.toUpperCase(),
                                                style: const TextStyle(
                                                  fontFamily: 'JetBrains Mono',
                                                  color: AppColors.success,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          // Unverified alert banner
                                          Text(
                                            'Unverified — not confirmed by ${room.domain}'.toUpperCase(),
                                            style: const TextStyle(
                                              fontFamily: 'JetBrains Mono',
                                              color: AppColors.muted,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // Join State Action Button
                                  GestureDetector(
                                    onTap: () => _onRoomPressed(room),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isJoined 
                                            ? AppColors.primary.withOpacity(0.08) 
                                            : AppColors.cta,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        isJoined ? 'JOINED' : 'JOIN',
                                        style: TextStyle(
                                          fontFamily: 'JetBrains Mono',
                                          color: isJoined ? AppColors.primary : Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Link to create new room
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Can't find your room?",
                        style: TextStyle(fontFamily: 'Outfit', color: AppColors.muted),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OrganizationSetupScreen()),
                          );
                        },
                        child: const Text(
                          'Create one',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: AppColors.violet,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
