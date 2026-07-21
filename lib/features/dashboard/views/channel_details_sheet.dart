import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';

class ChannelDetailsSheet extends StatefulWidget {
  const ChannelDetailsSheet({super.key, required this.channel});

  final OrgChannel channel;

  @override
  State<ChannelDetailsSheet> createState() => _ChannelDetailsSheetState();
}

class _ChannelDetailsSheetState extends State<ChannelDetailsSheet> {
  bool _muteNotifications = false;
  bool _pinChannel = false;

  void _showAddParticipantDialog(BuildContext context, ApiRepository repo) {
    final channelId = widget.channel.id;
    final Set<String> selectedContactIds = {};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Consumer<ApiRepository>(
              builder: (context, repo, child) {
                final activeList = repo.getChannelParticipants(channelId);
                final availableContacts = repo.contacts.where((c) => !activeList.any((p) => p.id == c.id)).toList();

                return AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Person to Channel',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  titlePadding: const EdgeInsets.only(left: 24, right: 12, top: 16, bottom: 8),
                  content: availableContacts.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'All organization contacts are already members of this channel.',
                            style: TextStyle(fontFamily: 'Outfit', color: AppColors.muted, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : SizedBox(
                          width: double.maxFinite,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: availableContacts.length,
                            separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                            itemBuilder: (context, index) {
                              final contact = availableContacts[index];
                              final isSelected = selectedContactIds.contains(contact.id);
                              final avatarUrl = 'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(contact.name)}';

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(avatarUrl),
                                ),
                                title: Text(
                                  contact.name,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  contact.category,
                                  style: const TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 9,
                                    color: AppColors.muted,
                                  ),
                                ),
                                trailing: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.success : AppColors.violet.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isSelected ? Icons.check_rounded : Icons.add_rounded,
                                    color: isSelected ? Colors.white : AppColors.violet,
                                    size: 16,
                                  ),
                                ),
                                onTap: () {
                                  setDialogState(() {
                                    if (isSelected) {
                                      selectedContactIds.remove(contact.id);
                                    } else {
                                      selectedContactIds.add(contact.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        int addedCount = 0;
                        for (final contactId in selectedContactIds) {
                          try {
                            final contact = availableContacts.firstWhere((c) => c.id == contactId);
                            repo.addParticipantToChannel(channelId, contact);
                            addedCount++;
                          } catch (e) {
                            debugPrint('⚠️ Contact already added or not found: $e');
                          }
                        }

                        Navigator.pop(context);

                        if (addedCount > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $addedCount member(s) to #${widget.channel.name}!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final list = repo.getChannelParticipants(widget.channel.id);

    // Map contacts list to maps for rendering
    final participants = [
      if (repo.currentUser != null)
        {
          'id': 'current_user',
          'name': '${repo.currentUser!.name} (You)',
          'role': repo.currentUser!.role,
          'avatar': repo.currentUser!.avatarUrl ?? 'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(repo.currentUser!.name)}'
        },
      ...list.map((c) => {
            'id': c.id,
            'name': c.name,
            'role': c.category,
            'avatar': 'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(c.name)}'
          }),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Sliding handle
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
          const SizedBox(height: 18),

          // 2. Channel Title info
          Row(
            children: [
              const Text(
                '#',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.violet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.channel.name,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Official channel workspace topic',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 18),

          // 3. Settings Toggles
          _buildToggleRow('Mute Notifications', _muteNotifications, (val) {
            setState(() {
              _muteNotifications = val;
            });
          }),
          _buildToggleRow('Pin Channel to top', _pinChannel, (val) {
            setState(() {
              _pinChannel = val;
            });
          }),

          const SizedBox(height: 18),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 18),

          // 4. Participants List Header with Add Member
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE MEMBERS (${participants.length})',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => _showAddParticipantDialog(context, repo),
                child: const Row(
                  children: [
                    Icon(Icons.person_add_alt_1_rounded, color: AppColors.violet, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'ADD PERSON',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.violet,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: participants.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = participants[index];
                final isMe = p['id'] == 'current_user';

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(p['avatar']!),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p['name']!,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p['role']!.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (!isMe) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          repo.removeParticipantFromChannel(widget.channel.id, p['id']!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${p['name']} removed from #${widget.channel.name}.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.remove_circle_outline_rounded,
                          color: Colors.red.withOpacity(0.8),
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Action close button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close Details'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, bool val, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          Switch.adaptive(
            value: val,
            activeColor: AppColors.cta,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
