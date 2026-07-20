import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/repositories/api_repository.dart';
import 'domain_verification_screen.dart';

class RoomSettingsScreen extends StatefulWidget {
  const RoomSettingsScreen({super.key});

  @override
  State<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends State<RoomSettingsScreen> {
  late bool _isOpenMode;

  @override
  void initState() {
    super.initState();
    final repo = Provider.of<ApiRepository>(context, listen: false);
    _isOpenMode = repo.currentRoom?.joinMode == 'Open';
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final roomName = repo.currentRoom?.name ?? 'Emantra Workspace';
    final isVerified = repo.currentRoom?.isVerified ?? true;

    final members = [
      if (repo.currentUser != null)
        {
          'name': repo.currentUser!.name,
          'role': repo.currentUser!.role,
          'email': repo.currentUser!.email,
          'avatar': repo.currentUser!.avatarUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'
        },
    ];

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
          'Room Settings',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w800,
            fontSize: 20,
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
              // 1. Room Name Title Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        roomName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roomName,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isVerified)
                            const Row(
                              children: [
                                Icon(Icons.verified, color: AppColors.success, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'OFFICIAL VERIFIED ROOM',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    color: AppColors.success,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'UNVERIFIED DOMAIN PARTITION',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                color: AppColors.cta,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Re-verify Action
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DomainVerificationScreen()),
                        );
                      },
                      child: Text(
                        isVerified ? 'RE-VERIFY' : 'VERIFY',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.violet,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Join Mode Toggle
              const Text(
                'JOIN PRIVILEGES',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOpenMode ? 'Open Membership' : 'Invite-only Membership',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isOpenMode 
                                ? 'Any same-domain user can auto-join.'
                                : 'Admin approval/manual invite required.',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch.adaptive(
                      value: _isOpenMode,
                      activeColor: AppColors.cta,
                      onChanged: (val) {
                        setState(() {
                          _isOpenMode = val;
                        });
                        repo.setJoinMode(val ? 'Open' : 'Invite-only');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. Members List Section
              const Text(
                'ROOM MEMBERS',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final m = members[index];
                  final isAdmin = m['role'] == 'Admin';

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(m['avatar']!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['name']!,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                m['email']!,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAdmin ? AppColors.cta.withOpacity(0.08) : AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            m['role']!.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: isAdmin ? AppColors.cta : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Danger Delete room
              OutlinedButton(
                onPressed: () {
                  repo.deleteRoom();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Room workspace partition deleted successfully.'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Delete room',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
