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

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context, listen: false);
    final participants = [
      if (repo.currentUser != null)
        {
          'name': repo.currentUser!.name,
          'role': repo.currentUser!.role,
          'avatar': repo.currentUser!.avatarUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'
        },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
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

          // 4. Participants List
          const Text(
            'ACTIVE PARTICIPANTS',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: participants.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = participants[index];

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
                ],
              );
            },
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
