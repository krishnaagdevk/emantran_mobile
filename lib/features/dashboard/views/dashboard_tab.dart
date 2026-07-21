import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/overlapping_bento_card.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';
import '../../events/views/event_detail_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key, required this.onSwitchRoom});

  final VoidCallback onSwitchRoom;

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _agentController = TextEditingController();
  String _searchQuery = '';
  int _selectedDateIndex = 0; // Dynamic selection index
  String? _lastRoomId; // Tracker for active workspace switches
  bool _isAgentLoading = false;
  String? _agentReply;
  String? _agentAction;

  @override
  void dispose() {
    _searchController.dispose();
    _agentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final roomName = repo.currentRoom?.name ?? 'Emantra Workspace';
    final roomVerified = repo.currentRoom?.isVerified ?? true;
    final roomId = repo.currentRoom?.id;

    if (_lastRoomId != roomId) {
      _lastRoomId = roomId;
      _selectedDateIndex = 0;
    }

    // Generate dates dynamically from actual events in the active workspace
    final List<Map<String, String>> dynamicDates = [];
    final Set<String> addedDays = {};

    final sortedEvents = List<OrgEvent>.from(repo.events)
      ..sort((a, b) {
        final dateA = a.rawDateTime ?? DateTime.now();
        final dateB = b.rawDateTime ?? DateTime.now();
        return dateA.compareTo(dateB);
      });

    for (final e in sortedEvents) {
      final dt = e.rawDateTime ?? DateTime.now();
      const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      final dayStr = weekdays[dt.weekday - 1];
      final numStr = dt.day.toString().padLeft(2, '0');

      // Unique day key using year-month-day to prevent duplicates
      final dayKey = '${dt.year}-${dt.month}-${dt.day}';
      if (!addedDays.contains(dayKey)) {
        addedDays.add(dayKey);
        dynamicDates.add({
          'day': dayStr,
          'num': numStr,
          'dateKey': e.dateText,
          'year': dt.year.toString(),
          'month': dt.month.toString(),
          'dayNum': dt.day.toString(),
        });
      }
    }

    final activeIndex = dynamicDates.isEmpty ? 0 : _selectedDateIndex.clamp(0, dynamicDates.length - 1);

    // Filter events based on search query AND active carousel selection
    final filteredEvents = repo.events.where((e) {
      // Date filter using raw year/month/day calendar dates
      if (dynamicDates.isNotEmpty) {
        final selectedDate = dynamicDates[activeIndex];
        final selYear = int.parse(selectedDate['year']!);
        final selMonth = int.parse(selectedDate['month']!);
        final selDay = int.parse(selectedDate['dayNum']!);

        final edt = e.rawDateTime ?? DateTime.now();
        if (edt.year != selYear || edt.month != selMonth || edt.day != selDay) {
          return false;
        }
      }
      
      // Search query filter
      if (_searchQuery.isEmpty) return true;
      return e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.venue.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Separate Live Now and Upcoming
    final liveEvents = filteredEvents.where((e) => e.isLive).toList();
    final upcomingEvents = filteredEvents.where((e) => !e.isLive).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // 1. Fixed Header: Room Switched Pill & Search
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room/Channel Switcher Pill
              GestureDetector(
                onTap: widget.onSwitchRoom,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary, // Deep purple #372475
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x101E1B1A),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.cta,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        roomName.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (roomVerified)
                        const Icon(Icons.verified, color: AppColors.success, size: 14)
                      else
                        const Icon(Icons.warning, color: AppColors.cta, size: 14),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Events',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontSize: 28,
                        ),
                  ),
                  if (!roomVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.muted.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'UNVERIFIED',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        if (repo.events.isNotEmpty) ...[
          const SizedBox(height: 16),

          // 2. Monospace Date Carousel
          SizedBox(
            height: 64,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: dynamicDates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final d = dynamicDates[index];
                final isSelected = activeIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDateIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cta : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : AppColors.border,
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.cta.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          d['day']!,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          d['num']!,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 3. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        hintText: 'Search events or venues...',
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
        ],

        const SizedBox(height: 16),

        // 3.5. Emantran AI Assistant Command Panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.08),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.psychology_outlined,
                      color: AppColors.cta, // Coral `#EF8A62`
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ask Emantran AI',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cta.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AGENT',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cta,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter a command to generate copywriting notes, schedule events, or create contacts.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 1.2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _agentController,
                          enabled: !_isAgentLoading,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Draft meetup next Monday...',
                            hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isAgentLoading
                          ? null
                          : () async {
                              final text = _agentController.text.trim();
                              if (text.isEmpty) return;

                              setState(() {
                                _isAgentLoading = true;
                                _agentReply = null;
                                _agentAction = null;
                              });

                              try {
                                final res = await repo.askAgent(text);
                                setState(() {
                                  _agentReply = res['reply'];
                                  _agentAction = res['action'];
                                  _agentController.clear();
                                });
                              } catch (e) {
                                setState(() {
                                  _agentReply = e.toString().replaceAll('Exception: ', '');
                                });
                              } finally {
                                setState(() {
                                  _isAgentLoading = false;
                                });
                              }
                            },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.cta,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _isAgentLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_agentReply != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.muted.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_agentAction != null && _agentAction != 'none') ...[
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.cta,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ACTION: ${_agentAction!.toUpperCase().replaceAll('_', ' ')}',
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cta,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          _agentReply!,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 4. Scrollable Event Sections
        if (repo.isSyncing && repo.events.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Synchronizing events...',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (repo.syncError != null && repo.events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.muted,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Connection Error',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    repo.syncError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => repo.refresh(),
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text('Retry Sync'),
                  ),
                ],
              ),
            ),
          )
        else if (repo.events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.cta.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: AppColors.cta,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No events scheduled yet',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "This workspace doesn't have any active events. Create your first event by clicking '+' below, or ask Emantran AI above to schedule one!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.muted,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (filteredEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    color: AppColors.muted,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No matches found',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No events match "$_searchQuery"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // A. LIVE NOW Section
                  if (liveEvents.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.sensors_rounded, color: AppColors.cta, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'LIVE NOW',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cta,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: liveEvents.length,
                      itemBuilder: (context, index) {
                        final event = liveEvents[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                              );
                            },
                            child: OverlappingBentoCard(
                              cardHeight: 200,
                              overlapAmount: 24,
                              tagText: 'LIVE - 74% RSVP',
                              badgeText: event.dateText,
                              headerArt: event.bannerUrl != null && event.bannerUrl!.isNotEmpty
                                  ? Image.network(
                                      event.bannerUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600',
                                      fit: BoxFit.cover,
                                    ),
                              overlapContent: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    event.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, color: AppColors.muted, size: 13),
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
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // B. UPCOMING Section
                  if (upcomingEvents.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'UPCOMING EVENTS',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingEvents.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = upcomingEvents[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border, width: 1.2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x021E1B1A),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Left accent bar (brand purple)
                                  Container(
                                    width: 5,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Left Column: Date block
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      event.dateText,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Main Column details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, color: AppColors.muted, size: 12),
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
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 10),
                                  // Price badge / indicator
                                  Container(
                                    margin: const EdgeInsets.only(right: 14),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: event.isFree 
                                          ? AppColors.success.withOpacity(0.08) 
                                          : AppColors.violet.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      event.isFree ? 'FREE' : '\$${event.price.toInt()}',
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: event.isFree ? AppColors.success : AppColors.violet,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
      ],
    ),
  );
  }
}
