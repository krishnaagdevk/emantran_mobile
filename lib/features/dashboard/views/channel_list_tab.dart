import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';
import 'dm_chat_screen.dart';
import 'channel_details_sheet.dart';
import 'channel_chat_screen.dart';

class ChannelListTab extends StatefulWidget {
  const ChannelListTab({super.key});

  @override
  State<ChannelListTab> createState() => _ChannelListTabState();
}

class _ChannelListTabState extends State<ChannelListTab> {
  final _channelNameController = TextEditingController();

  void _showAddChannelBottomSheet() {
    _channelNameController.clear();
    bool isPrivate = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setModalState) {
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
                      'Add Channel',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Channel Name input
                    TextFormField(
                      controller: _channelNameController,
                      autofocus: true,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'CHANNEL NAME',
                        hintText: 'e.g. design-squad',
                        prefixText: isPrivate ? '🔒 ' : '# ',
                        prefixStyle: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Private Toggle Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Private Channel',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'By invitation only, locked workspace.',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                color: AppColors.muted.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: isPrivate,
                          activeColor: AppColors.cta,
                          onChanged: (val) {
                            setModalState(() {
                              isPrivate = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: () {
                        final text = _channelNameController.text.trim();
                        if (text.isNotEmpty) {
                          final repo = Provider.of<ApiRepository>(context, listen: false);
                          repo.addChannel(
                            text.replaceAll(' ', '-').toLowerCase(),
                            isPrivate: isPrivate,
                          );
                          _channelNameController.clear();
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isPrivate
                                    ? 'Private channel "🔒 $text" added successfully!'
                                    : 'Channel "#$text" added successfully!',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      child: const Text('Add to list'),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    super.dispose();
  }

  void _showChannelDetails(OrgChannel channel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChannelDetailsSheet(channel: channel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final room = repo.currentRoom;
    final roomName = room?.name ?? 'Emantra Workspace';
    final isVerified = room?.isVerified ?? true;
    final channels = repo.channels;
    final contacts = repo.contacts;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Room Header Block
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
            child: Row(
              children: [
                // Logo Initial circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    roomName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              roomName,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (isVerified)
                            const Icon(Icons.verified, color: AppColors.success, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${contacts.length} MEMBERS · ACTIVE CHANNELS',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.border, height: 1),

          // 2. Channels Title & Add Channel Trigger
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CHANNELS',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted.withOpacity(0.8),
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: _showAddChannelBottomSheet,
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: AppColors.violet, size: 14),
                      SizedBox(width: 2),
                      Text(
                        'ADD',
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
          ),

          // 3. Channel Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: channels.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final channel = channels[index];
              final hasUnread = channel.unreadCount > 0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: hasUnread ? AppColors.primary.withOpacity(0.03) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChannelChatScreen(channel: channel),
                          ),
                        );
                      },
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      leading: channel.isPrivate
                          ? Icon(
                              Icons.lock_outline_rounded,
                              color: hasUnread ? AppColors.violet : AppColors.muted,
                              size: 18,
                            )
                          : Text(
                              '#',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: hasUnread ? AppColors.violet : AppColors.muted,
                              ),
                            ),
                      title: Text(
                        channel.name,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 15,
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                          color: hasUnread ? AppColors.ink : AppColors.muted,
                        ),
                      ),
                      trailing: hasUnread
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.cta,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${channel.unreadCount}',
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // 4. Direct Messages
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'DIRECT MESSAGES',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted.withOpacity(0.8),
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Horizontal scrollable DMs avatars list / empty state
          contacts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary.withOpacity(0.6), size: 18),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'No contacts inside this organization room yet. Tap the Book icon below to invite colleagues!',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              color: AppColors.muted,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 90,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: contacts.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      final c = contacts[index];
                      final avatarUrl = 'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(c.name)}';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DMChatScreen(
                                name: c.name,
                                role: c.category.toUpperCase(),
                                avatar: avatarUrl,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(avatarUrl),
                                  backgroundColor: AppColors.primary.withOpacity(0.08),
                                ),
                                // Online indicator dot
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.surface, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.name.split(' ').first,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
