import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/asymmetric_bottom_nav_bar.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';
import '../../events/views/create_event_screen.dart';
import '../../contacts/views/contacts_list_tab.dart';
import '../../profile/views/profile_tab.dart';
import 'dashboard_tab.dart';
import 'channel_list_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _onAddEventPressed() {
    // Elegant fullscreen slide-up transition representing a premium modal overlay
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showRoomSwitcherBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Consumer<ApiRepository>(
            builder: (context, repo, child) {
              final domain = repo.currentUser?.domain ?? 'emantra.app';
              final rooms = repo.availableRooms.where((r) => r.domain.toLowerCase() == domain.toLowerCase()).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.faint.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Switch Room Partition',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Discovered rooms matching @$domain domain',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: rooms.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        final isSelected = repo.currentRoom?.id == room.id;

                        return GestureDetector(
                          onTap: () {
                            repo.selectRoom(room);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Switched workspace to "${room.name}"'),
                                backgroundColor: AppColors.primary,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.primary.withOpacity(0.04) 
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.8 : 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.06),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    room.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: isSelected ? Colors.white : AppColors.primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    room.name,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (room.isVerified)
                                  const Icon(Icons.verified, color: AppColors.success, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tab definitions
    final List<Widget> tabs = [
      DashboardTab(onSwitchRoom: _showRoomSwitcherBottomSheet),
      const ChannelListTab(),
      const ContactsListTab(),
      const ProfileTab(),
    ];

    return AtmosphericBlobs(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let blurs shine
        body: SafeArea(
          bottom: false, // Nav bar handles bottom notches gracefully
          child: IndexedStack(
            index: _currentTabIndex,
            children: tabs,
          ),
        ),
        bottomNavigationBar: AsymmetricBottomNavBar(
          currentIndex: _currentTabIndex,
          onTabSelected: _onTabSelected,
          onAddEventPressed: _onAddEventPressed,
        ),
      ),
    );
  }
}
