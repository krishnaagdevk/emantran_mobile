# Graph Report - mobile_client  (2026-07-20)

## Corpus Check
- 77 files · ~209,310 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 800 nodes · 1194 edges · 52 communities (48 shown, 4 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ad4e0096`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Win32Window
- api_repository.dart
- models.dart
- AppDelegate
- forgot_password_screen.dart
- splash_screen.dart
- dashboard_tab.dart
- my_application.cc
- login_screen.dart
- app_colors.dart
- frameless_text_field.dart
- add_edit_contact_screen.dart
- main.dart
- create_event_screen.dart
- contacts_list_tab.dart
- dashboard_screen.dart
- settings_screen.dart
- event_rsvp_list_screen.dart
- event_rsvp_signup_screen.dart
- data/repositories/api_repository.dart
- event_invite_screen.dart
- event_rsvp_confirmation_screen.dart
- mock_api_repository.dart
- reset_password_screen.dart
- domain_verification_screen.dart
- dm_chat_screen.dart
- wWinMain
- channel_chat_screen.dart
- organization_setup_screen.dart
- channel_list_tab.dart
- channel_details_sheet.dart
- manifest.json
- ApiRepository
- State
- overlapping_bento_card.dart
- event_detail_screen.dart
- package:flutter/material.dart
- asymmetric_bottom_nav_bar.dart
- StatelessWidget
- room_discovery_screen.dart
- app_typography.dart
- status_chip.dart
- ../../app/theme/app_colors.dart
- split_pill_date_selector.dart
- MainActivity
- mobile_client
- README.md
- String?

## God Nodes (most connected - your core abstractions)
1. `ApiRepository` - 76 edges
2. `Win32Window` - 22 edges
3. `MessageHandler` - 12 edges
4. `FlutterWindow` - 10 edges
5. `Create` - 10 edges
6. `WndProc` - 10 edges
7. `MessageHandler` - 9 edges
8. `OrgEvent` - 7 edges
9. `_MyApplication` - 7 edges
10. `OnCreate` - 7 edges

## Surprising Connections (you probably didn't know these)
- `_submit` --references--> `ApiRepository`  [EXTRACTED]
  lib/features/auth/views/login_screen.dart → lib/data/repositories/api_repository.dart
- `_submit` --references--> `ApiRepository`  [EXTRACTED]
  lib/features/auth/views/register_screen.dart → lib/data/repositories/api_repository.dart
- `build` --references--> `ApiRepository`  [EXTRACTED]
  lib/features/contacts/views/add_edit_contact_screen.dart → lib/data/repositories/api_repository.dart
- `_delete` --references--> `ApiRepository`  [EXTRACTED]
  lib/features/contacts/views/add_edit_contact_screen.dart → lib/data/repositories/api_repository.dart
- `_save` --references--> `ApiRepository`  [EXTRACTED]
  lib/features/contacts/views/add_edit_contact_screen.dart → lib/data/repositories/api_repository.dart

## Import Cycles
- None detected.

## Communities (52 total, 4 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "api_repository.dart"
Cohesion: 0.04
Nodes (55): AppUser? get, dart:io, addChannel, addContact, addGuest, addParticipantToChannel, askAgent, _availableRooms (+47 more)

### Community 2 - "models.dart"
Cohesion: 0.04
Nodes (53): int get, acceptedCount, AppUser, avatarUrl, bannerUrl, bridesFamily, category, channelId (+45 more)

### Community 3 - "AppDelegate"
Cohesion: 0.06
Nodes (26): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+18 more)

### Community 4 - "forgot_password_screen.dart"
Cohesion: 0.14
Nodes (14): build, _buildInputState, _buildSuccessState, createState, dispose, _emailController, ForgotPasswordScreen, _ForgotPasswordScreenState (+6 more)

### Community 5 - "splash_screen.dart"
Cohesion: 0.13
Nodes (15): Animation, build, _controller, createState, dispose, _fadeAnimation, initState, onFinished (+7 more)

### Community 6 - "dashboard_tab.dart"
Cohesion: 0.07
Nodes (28): ../../../app/widgets/overlapping_bento_card.dart, Color, ../../events/views/event_detail_screen.dart, build, _confirmController, createState, dispose, _emailController (+20 more)

### Community 7 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 8 - "login_screen.dart"
Cohesion: 0.10
Nodes (21): dart:async, forgot_password_screen.dart, build, createState, _currentPage, dispose, _emailController, _formKey (+13 more)

### Community 9 - "app_colors.dart"
Cohesion: 0.09
Nodes (21): AppColors, AppShadows, blobCoral, blobLavender, border, canvas, cardShadow, cta (+13 more)

### Community 10 - "frameless_text_field.dart"
Cohesion: 0.06
Nodes (37): FocusNode, _AtmosphericTextFocusTracker, build, controller, createState, dispose, _focusNode, FramelessTextField (+29 more)

### Community 11 - "add_edit_contact_screen.dart"
Cohesion: 0.11
Nodes (18): bool get, AppContact, AddEditContactScreen, _AddEditContactScreenState, build, contact, createState, _delete (+10 more)

### Community 12 - "main.dart"
Cohesion: 0.12
Nodes (16): app/theme/app_theme.dart, features/auth/views/role_selection_screen.dart, features/dashboard/views/dashboard_screen.dart, features/splash/splash_screen.dart, apiUrl, AppConfig, r2PublicUrl, AppEntryPoint (+8 more)

### Community 13 - "create_event_screen.dart"
Cohesion: 0.12
Nodes (17): ../../../app/widgets/split_pill_date_selector.dart, DateTime, build, CreateEventScreen, _CreateEventScreenState, createState, dispose, _formKey (+9 more)

### Community 14 - "contacts_list_tab.dart"
Cohesion: 0.13
Nodes (15): add_edit_contact_screen.dart, ContactsListTab, _ContactsListTabState, createState, dispose, _emailController, _expandedContactId, _nameController (+7 more)

### Community 15 - "dashboard_screen.dart"
Cohesion: 0.13
Nodes (15): ../../../app/widgets/asymmetric_bottom_nav_bar.dart, channel_list_tab.dart, ../../contacts/views/contacts_list_tab.dart, dashboard_tab.dart, ../../events/views/create_event_screen.dart, build, createState, _currentTabIndex (+7 more)

### Community 16 - "settings_screen.dart"
Cohesion: 0.12
Nodes (16): build, _buildGroupDecoration, _buildGroupHeader, _buildToggleRow, _compactView, createState, _darkMode, _notifAccepted (+8 more)

### Community 17 - "event_rsvp_list_screen.dart"
Cohesion: 0.07
Nodes (27): ../../../app/widgets/status_chip.dart, event_rsvp_confirmation_screen.dart, build, _buildCategoryFilter, _buildSegmentedFilter, _buildStatusActionButton, createState, dispose (+19 more)

### Community 18 - "event_rsvp_signup_screen.dart"
Cohesion: 0.17
Nodes (12): AnimationController, dart:math, dart:ui, AtmosphericBlobs, _AtmosphericBlobsState, build, child, _controller (+4 more)

### Community 19 - "data/repositories/api_repository.dart"
Cohesion: 0.16
Nodes (12): data/repositories/api_repository.dart, domain_verification_screen.dart, createState, initState, _isOpenMode, RoomSettingsScreen, _RoomSettingsScreenState, _buildSettingRow (+4 more)

### Community 20 - "event_invite_screen.dart"
Cohesion: 0.15
Nodes (13): _autofillFromContact, build, createState, dispose, _emailController, event, EventInviteScreen, _EventInviteScreenState (+5 more)

### Community 21 - "event_rsvp_confirmation_screen.dart"
Cohesion: 0.25
Nodes (7): OrgEvent, build, event, guestName, isAttending, paint, shouldRepaint

### Community 22 - "mock_api_repository.dart"
Cohesion: 0.15
Nodes (12): dart:convert, avatarUrl, email, fetchMockUser, fromJson, id, loadMasterDataset, MockDataService (+4 more)

### Community 23 - "reset_password_screen.dart"
Cohesion: 0.15
Nodes (13): _assessPasswordStrength, build, _buildStrengthMeter, _confirmController, createState, dispose, _formKey, initState (+5 more)

### Community 24 - "domain_verification_screen.dart"
Cohesion: 0.17
Nodes (12): int?, build, _buildMethodsState, _buildSuccessState, _buildVerifyingState, createState, DomainVerificationScreen, _DomainVerificationScreenState (+4 more)

### Community 25 - "dm_chat_screen.dart"
Cohesion: 0.20
Nodes (9): accepted, build, _buildGridCard, _buildLegendRow, declined, event, paint, pending (+1 more)

### Community 26 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 27 - "channel_chat_screen.dart"
Cohesion: 0.18
Nodes (11): build, channel, ChannelChatScreen, _ChannelChatScreenState, createState, dispose, initState, _messageController (+3 more)

### Community 28 - "organization_setup_screen.dart"
Cohesion: 0.18
Nodes (11): ../../../app/widgets/frameless_text_field.dart, FormState, build, _createRoom, createState, dispose, _formKey, OrganizationSetupScreen (+3 more)

### Community 29 - "channel_list_tab.dart"
Cohesion: 0.20
Nodes (10): channel_chat_screen.dart, channel_details_sheet.dart, dm_chat_screen.dart, ChannelListTab, _ChannelListTabState, _channelNameController, createState, dispose (+2 more)

### Community 30 - "channel_details_sheet.dart"
Cohesion: 0.20
Nodes (10): OrgChannel, build, _buildToggleRow, channel, ChannelDetailsSheet, _ChannelDetailsSheetState, createState, _muteNotifications (+2 more)

### Community 31 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 32 - "ApiRepository"
Cohesion: 0.33
Nodes (10): ChangeNotifier, ApiRepository, build, build, build, build, build, build (+2 more)

### Community 33 - "State"
Cohesion: 0.25
Nodes (8): CustomPainter, CelebrationArtPainter, EnvelopeTrajectoryPainter, BrokenEnvelopePainter, DonutChartPainter, TimelineLineChartPainter, GeometricQRCodePainter, BrandMarkPainter

### Community 34 - "overlapping_bento_card.dart"
Cohesion: 0.18
Nodes (10): badgeText, build, cardHeight, headerArt, overlapAmount, overlapContent, paint, shouldRepaint (+2 more)

### Community 35 - "event_detail_screen.dart"
Cohesion: 0.22
Nodes (8): analytics_screen.dart, ../../../data/models/models.dart, event_invite_screen.dart, event_rsvp_list_screen.dart, _buildDetailMetaRow, _buildRSVPMetric, _buildSegmentedBar, event

### Community 36 - "package:flutter/material.dart"
Cohesion: 0.50
Nodes (3): package:Emantran/main.dart, package:flutter_test/flutter_test.dart, main

### Community 37 - "asymmetric_bottom_nav_bar.dart"
Cohesion: 0.25
Nodes (7): AsymmetricBottomNavBar, build, _buildNavItem, currentIndex, onAddEventPressed, onTabSelected, ValueChanged

### Community 38 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): OverlappingBentoCard, RoleSelectionScreen, Error404Screen, AnalyticsScreen, EventDetailScreen, EventRSVPConfirmationScreen, ProfileTab, StatelessWidget

### Community 39 - "room_discovery_screen.dart"
Cohesion: 0.29
Nodes (7): createState, _joinedRoomIds, _onRoomPressed, RoomDiscoveryScreen, _RoomDiscoveryScreenState, organization_setup_screen.dart, Set

### Community 40 - "app_typography.dart"
Cohesion: 0.18
Nodes (10): app_colors.dart, AppTheme, AppTypography, fontMono, fontSans, mono, sans, package:flutter/material.dart (+2 more)

### Community 41 - "status_chip.dart"
Cohesion: 0.29
Nodes (6): build, compact, GuestStatus, status, StatusChip, ../theme/app_colors.dart

### Community 42 - "../../app/theme/app_colors.dart"
Cohesion: 0.18
Nodes (10): ../../../app_config.dart, ../../app/theme/app_colors.dart, ../../../app/widgets/atmospheric_blobs.dart, ../../dashboard/views/dashboard_screen.dart, build, _buildBannerCard, build, paint (+2 more)

### Community 43 - "split_pill_date_selector.dart"
Cohesion: 0.33
Nodes (5): build, onTap, selectedDateText, SplitPillDateSelector, VoidCallback

## Knowledge Gaps
- **411 isolated node(s):** `AppColors`, `AppShadows`, `canvas`, `surface`, `ink` (+406 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ApiRepository` connect `ApiRepository` to `api_repository.dart`, `dashboard_tab.dart`, `login_screen.dart`, `add_edit_contact_screen.dart`, `main.dart`, `create_event_screen.dart`, `contacts_list_tab.dart`, `dashboard_screen.dart`, `event_rsvp_list_screen.dart`, `data/repositories/api_repository.dart`, `event_invite_screen.dart`, `domain_verification_screen.dart`, `dm_chat_screen.dart`, `channel_chat_screen.dart`, `organization_setup_screen.dart`, `channel_list_tab.dart`, `channel_details_sheet.dart`, `event_detail_screen.dart`, `StatelessWidget`, `room_discovery_screen.dart`?**
  _High betweenness centrality (0.108) - this node is a cross-community bridge._
- **Why does `OrgEvent` connect `event_rsvp_confirmation_screen.dart` to `models.dart`, `event_detail_screen.dart`, `event_rsvp_list_screen.dart`, `event_invite_screen.dart`, `dm_chat_screen.dart`?**
  _High betweenness centrality (0.030) - this node is a cross-community bridge._
- **Why does `FlutterWindow` connect `Win32Window` to `AppDelegate`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `AppColors`, `AppShadows`, `canvas` to the rest of the system?**
  _411 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `api_repository.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03571428571428571 - nodes in this community are weakly interconnected._
- **Should `models.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.037037037037037035 - nodes in this community are weakly interconnected._