import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/status_chip.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';

class EventRSVPListScreen extends StatefulWidget {
  const EventRSVPListScreen({super.key, required this.event});

  final OrgEvent event;

  @override
  State<EventRSVPListScreen> createState() => _EventRSVPListScreenState();
}

class _EventRSVPListScreenState extends State<EventRSVPListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: ALL, 1: ACCEPTED, 2: PENDING, 3: DECLINED
  String? _expandedGuestId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final domain = repo.currentRoom?.domain ?? repo.currentUser?.domain ?? 'emantra.app';
    final guests = repo.guests;

    // Filter guests based on search and status tabs
    final filteredGuests = guests.where((g) {
      // 1. Search Query filter
      final matchesSearch = g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.email.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      // 2. Status tab filter
      if (_selectedFilterIndex == 0) return true;
      if (_selectedFilterIndex == 1) return g.status == GuestStatus.accepted;
      if (_selectedFilterIndex == 2) return g.status == GuestStatus.pending;
      if (_selectedFilterIndex == 3) return g.status == GuestStatus.declined;

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Guest List',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Event Brief Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                widget.event.title.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // 2. Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.ink),
                        decoration: const InputDecoration(
                          hintText: 'Search guests...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: const Icon(Icons.close_rounded, color: AppColors.muted, size: 18),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Segmented Status Filters
            _buildSegmentedFilter(),

            const SizedBox(height: 16),

            // 4. Guest List Cards
            Expanded(
              child: filteredGuests.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching guests found.',
                        style: TextStyle(fontFamily: 'Outfit', color: AppColors.muted),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredGuests.length,
                      itemBuilder: (context, index) {
                        final guest = filteredGuests[index];
                        final isExpanded = _expandedGuestId == guest.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isExpanded ? AppColors.violet : AppColors.border,
                              width: isExpanded ? 1.5 : 1.2,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      _expandedGuestId = isExpanded ? null : guest.id;
                                    });
                                  },
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primary.withOpacity(0.06),
                                    backgroundImage: guest.avatarUrl != null 
                                        ? NetworkImage(guest.avatarUrl!) 
                                        : null,
                                    child: guest.avatarUrl == null
                                        ? Text(
                                            guest.name.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(
                                              fontFamily: 'Outfit',
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    guest.name,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Text(
                                    guest.email,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: StatusChip(status: guest.status, compact: true),
                                ),
                              ),

                              // Expanded Panel containing details
                              if (isExpanded)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  color: AppColors.primary.withOpacity(0.02),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(color: AppColors.border, height: 1),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'MEMBER CATEGORY:',
                                            style: TextStyle(
                                              fontFamily: 'JetBrains Mono',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.06),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              guest.category.toUpperCase(),
                                              style: const TextStyle(
                                                fontFamily: 'JetBrains Mono',
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'INTERNAL LOGS',
                                        style: TextStyle(
                                          fontFamily: 'JetBrains Mono',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Official corporate invite issued automatically via domain matching for @$domain.',
                                        style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 12,
                                          color: AppColors.muted,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }

  Widget _buildSegmentedFilter() {
    final filters = ['ALL', 'ACCEPTED', 'PENDING', 'DECLINED'];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final title = filters[index];
          final active = _selectedFilterIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? Colors.transparent : AppColors.border,
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
