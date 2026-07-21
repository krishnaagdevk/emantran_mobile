import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, File; // Guarded imports of dart:io
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../app/widgets/status_chip.dart';
import '../models/models.dart';
import 'dart:io' as io; // Guarded alias

class ApiRepository extends ChangeNotifier {
  // --- API Endpoint Resolutions ---
  String get _baseUrl {
    if (kIsWeb) {
      try {
        return dotenv.get('API_URL', fallback: 'http://localhost:8080');
      } catch (_) {
        return 'http://localhost:8080';
      }
    }
    try {
      final envUrl = dotenv.get('API_URL', fallback: '');
      final isPhysical = dotenv.get('PHYSICAL_DEVICE', fallback: 'false') == 'true';
      if (envUrl.isNotEmpty) {
        if (io.Platform.isAndroid && envUrl.contains('localhost') && !isPhysical) {
          return envUrl.replaceAll('localhost', '10.0.2.2');
        }
        return envUrl;
      }
    } catch (_) {}
    
    // Default fallback (uses 10.0.2.2 for Android emulator, localhost otherwise)
    final isPhysicalDefault = dotenv.get('PHYSICAL_DEVICE', fallback: 'false') == 'true';
    if (io.Platform.isAndroid) {
      return isPhysicalDefault ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  // --- State Variables ---
  AppUser? _currentUser;
  String? _token;
  OrgRoom? _currentRoom;
  List<OrgRoom> _availableRooms = [];
  List<OrgChannel> _channels = [];
  List<OrgEvent> _events = [];
  List<AppContact> _contacts = [];
  List<EventGuest> _guests = [];
  final Map<String, List<AppContact>> _channelParticipants = {};
  Timer? _mockSseTimer;
  
  // Custom State for Password Resets and Chat persistence
  final Map<String, String> _resetTokens = {}; // email -> token
  final Map<String, List<ChatMessage>> _channelMessages = {};

  bool _isSyncing = false;
  String? _syncError;

  List<AppContact> getChannelParticipants(String channelId) {
    if (!_channelParticipants.containsKey(channelId)) {
      if (channelId == 'ch_announcements') {
        _channelParticipants[channelId] = _contacts.length >= 5
            ? [_contacts[0], _contacts[1], _contacts[3], _contacts[4]]
            : _contacts.take(2).toList();
      } else if (channelId == 'ch_general') {
        _channelParticipants[channelId] = _contacts.length >= 8
            ? [_contacts[2], _contacts[5], _contacts[6], _contacts[7]]
            : _contacts.take(2).toList();
      } else if (channelId == 'ch_rsvp_alerts') {
        _channelParticipants[channelId] = _contacts.length >= 10
            ? [_contacts[1], _contacts[8], _contacts[9]]
            : _contacts.take(2).toList();
      } else {
        _channelParticipants[channelId] = [];
      }
    }
    return _channelParticipants[channelId]!;
  }

  void addParticipantToChannel(String channelId, AppContact contact) {
    final list = getChannelParticipants(channelId);
    if (!list.any((c) => c.id == contact.id)) {
      list.add(contact);
      notifyListeners();
    }
  }

  List<ChatMessage> getChannelMessages(String channelId) {
    if (!_channelMessages.containsKey(channelId)) {
      if (channelId == 'ch_announcements') {
        _channelMessages[channelId] = [
          ChatMessage(
            id: 'm1',
            channelId: channelId,
            senderName: 'Sarah Jenkins',
            senderEmail: 'sarah.jenkins@adobe.com',
            text: 'Welcome to the Adobe Creative Space room! We will post all official event announcements here.',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ];
      } else if (channelId == 'ch_general') {
        _channelMessages[channelId] = [
          ChatMessage(
            id: 'm1',
            channelId: channelId,
            senderName: 'Marcus Vance',
            senderEmail: 'marcus.vance@adobe.com',
            text: 'Hi everyone, is anyone free to help with the Summer Gala stage prep tomorrow?',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'm2',
            channelId: channelId,
            senderName: 'Sarah Jenkins',
            senderEmail: 'sarah.jenkins@adobe.com',
            text: "I am free in the afternoon, Marcus! Let's synchronize offline.",
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];
      } else if (channelId == 'ch_rsvp_alerts') {
        _channelMessages[channelId] = [
          ChatMessage(
            id: 'm1',
            channelId: channelId,
            senderName: 'Emantra Bot',
            senderEmail: 'bot@emantra.app',
            text: 'Live RSVP SSE stream initialized successfully for room: Creative Space.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ];
      } else {
        _channelMessages[channelId] = [
          ChatMessage(
            id: 'm1',
            channelId: channelId,
            senderName: 'Emantra Bot',
            senderEmail: 'bot@emantra.app',
            text: 'Welcome to the start of the new channel!',
            timestamp: DateTime.now(),
          ),
        ];
      }
    }
    return _channelMessages[channelId]!;
  }

  void sendChannelMessage(String channelId, String text) {
    final messages = getChannelMessages(channelId);
    final user = _currentUser;
    final senderName = user?.name ?? 'Alex Morgan';
    final senderEmail = user?.email ?? 'alex.morgan@emantra.app';

    messages.add(ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      channelId: channelId,
      senderName: senderName,
      senderEmail: senderEmail,
      text: text,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // --- Getters ---
  AppUser? get currentUser => _currentUser;
  String? get token => _token;
  OrgRoom? get currentRoom => _currentRoom;
  List<OrgRoom> get availableRooms => List.unmodifiable(_availableRooms);
  List<OrgChannel> get channels => List.unmodifiable(
        _channels.where((c) => c.roomId == (_currentRoom?.id ?? '')),
      );

  List<OrgEvent> get events {
    final filtered = _events.where((e) => e.roomId == (_currentRoom?.id ?? '')).toList();
    return List.unmodifiable(filtered.map((e) {
      final eventGuests = _guests.where((g) => g.eventId == e.id).toList();
      if (eventGuests.isNotEmpty) {
        final accepted = eventGuests.where((g) => g.status == GuestStatus.accepted).length;
        final pending = eventGuests.where((g) => g.status == GuestStatus.pending).length;
        final declined = eventGuests.where((g) => g.status == GuestStatus.declined).length;
        return OrgEvent(
          id: e.id,
          roomId: e.roomId,
          title: e.title,
          hostName: e.hostName,
          dateText: e.dateText,
          timeText: e.timeText,
          venue: e.venue,
          notes: e.notes,
          price: e.price,
          isFree: e.isFree,
          isLive: e.isLive,
          bannerUrl: e.bannerUrl,
          rawDateTime: e.rawDateTime,
          acceptedCount: accepted,
          pendingCount: pending,
          declinedCount: declined,
        );
      }
      return e;
    }));
  }

  List<AppContact> get contacts => List.unmodifiable(_contacts..sort((a, b) => a.name.compareTo(b.name)));
  List<EventGuest> get guests => List.unmodifiable(_guests);

  List<EventGuest> guestsForEvent(String eventId) {
    return _guests.where((g) => g.eventId == eventId).toList();
  }

  bool get isSyncing => _isSyncing;
  String? get syncError => _syncError;

  bool get isMockMode {
    try {
      return dotenv.get('MOCK_DATA', fallback: 'false') == 'true';
    } catch (_) {
      return false;
    }
  }

  // --- Constructor Seed/Init ---
  ApiRepository() {
    _loadSeedFallbacks();
    _loadPersistedSession().then((_) {
      if (isMockMode) {
        _loadFromMockAsset();
      } else {
        _refreshFromBackend();
      }
    });
  }

  // --- 1. Seed Fallbacks (Strictly Online Mode - No Mock Offline Data) ---
  void _loadSeedFallbacks() {
    _channels = [];
  }

  // --- Session File-Caching Persistence Helpers ---
  Future<void> _loadPersistedSession() async {
    if (kIsWeb) return;
    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/emantran_session.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final userJson = json.decode(content);
        _currentUser = AppUser(
          id: userJson['id'],
          name: userJson['name'],
          email: userJson['email'],
          role: userJson['role'] ?? 'Member',
          avatarUrl: userJson['avatar_url'],
        );
        _token = userJson['token'];
        notifyListeners();
        debugPrint('🔑 Restored user session from file cache: ${_currentUser!.email}');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load user session cache: $e');
    }
  }

  Future<void> _savePersistedSession() async {
    if (kIsWeb) return;
    try {
      if (_currentUser != null) {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/emantran_session.json');
        final data = {
          'id': _currentUser!.id,
          'name': _currentUser!.name,
          'email': _currentUser!.email,
          'role': _currentUser!.role,
          'avatar_url': _currentUser!.avatarUrl,
          'token': _token,
        };
        await file.writeAsString(json.encode(data));
      }
    } catch (e) {
      debugPrint('⚠️ Failed to save user session cache: $e');
    }
  }

  Future<void> _clearPersistedSession() async {
    if (kIsWeb) return;
    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/emantran_session.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to clear user session cache: $e');
    }
  }

  // --- Mock Data Engine Service Loader ---
  Future<void> _loadFromMockAsset() async {
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      debugPrint('🎨 Loading centralized mock_data.json asset...');
      final jsonStr = await rootBundle.loadString('assets/mock_data.json');
      final data = json.decode(jsonStr);

      if (_currentUser == null && data['currentUser'] != null) {
        final userJson = data['currentUser'];
        _currentUser = AppUser(
          id: userJson['id'],
          name: userJson['name'],
          email: userJson['email'],
          role: userJson['role'] ?? 'Member',
          avatarUrl: userJson['avatar_url'],
        );
        _token = "mock-jwt-token-alex-morgan";
      }

      if (data['rooms'] != null) {
        final List roomsList = data['rooms'];
        _availableRooms = roomsList.map((j) => OrgRoom(
          id: j['id'],
          name: j['name'],
          domain: j['domain'],
          isVerified: j['is_verified'] == true,
          joinMode: j['join_mode'] ?? 'Invite-only',
        )).toList();
        if (_currentRoom == null && _availableRooms.isNotEmpty) {
          _currentRoom = _availableRooms.first;
        }
      }

      if (data['channels'] != null) {
        final List channelsList = data['channels'];
        _channels = channelsList.map((j) => OrgChannel(
          id: j['id'],
          roomId: j['room_id'] ?? 'rm_creative_space',
          name: j['name'],
          description: j['description'] ?? '',
          unreadCount: j['unread_count'] ?? 0,
          isPrivate: j['is_private'] == true,
        )).toList();
      }

      if (data['events'] != null) {
        final List eventsList = data['events'];
        _events = eventsList.map((j) {
          final dt = _parseDateTime(j['date_time'] ?? j['date']);
          return OrgEvent(
            id: j['id'],
            roomId: j['room_id'] ?? 'rm_creative_space',
            title: j['name'],
            hostName: j['host'] ?? _currentRoom?.name ?? 'Emantra Workspace',
            dateText: dt['dateText']!,
            timeText: dt['timeText']!,
            venue: j['location'] ?? j['venue'] ?? '',
            notes: j['description'] ?? j['notes'] ?? '',
            price: (j['price'] as num?)?.toDouble() ?? 0.0,
            isFree: j['is_free'] == true || (j['price'] == null || j['price'] == 0.0),
            isLive: j['is_live'] == true,
            bannerUrl: j['image_url'] ?? j['cover_url'],
            rawDateTime: DateTime.tryParse(j['date_time'] ?? j['date'] ?? ''),
            acceptedCount: j['accepted_count'] ?? 12,
            pendingCount: j['pending_count'] ?? 4,
            declinedCount: j['declined_count'] ?? 1,
          );
        }).toList();
      }

      if (data['contacts'] != null) {
        final List contactsList = data['contacts'];
        _contacts = contactsList.map((j) => AppContact(
          id: j['id'],
          name: j['name'],
          email: j['email'],
          phone: j['phone'] ?? '+1-555-0122',
          notes: j['notes'] ?? '',
          category: j['category'] ?? 'Colleague',
        )).toList();
      }

      if (data['guests'] != null) {
        final List guestsList = data['guests'];
        _guests = guestsList.map((j) {
          GuestStatus status = GuestStatus.pending;
          final statusStr = j['status']?.toString().toLowerCase() ?? '';
          if (statusStr == 'attending' || statusStr == 'accepted') {
            status = GuestStatus.accepted;
          } else if (statusStr == 'declined') {
            status = GuestStatus.declined;
          }
          String category = j['category'] ?? 'Colleague';
          if (category == 'Colleagues') category = 'Colleague';
          if (category == 'Friends') category = 'Friend';
          return EventGuest(
            id: j['id'],
            eventId: j['event_id'] ?? 'evt_summer_gala',
            name: j['name'],
            email: j['email'],
            avatarUrl: j['avatar_url'],
            status: status,
            category: category,
          );
        }).toList();
      }

      _syncError = null;
      debugPrint('✅ Unified mock database loaded successfully from assets!');
      _startMockSseSimulation();
    } catch (e) {
      debugPrint('⚠️ Mock data loader failed: $e');
      _syncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // --- 2. Synchronize Lists with Backend REST API ---
  Future<void> refresh() async {
    try {
      _syncError = null;
      if (isMockMode) {
        await _loadFromMockAsset();
      } else {
        await _refreshFromBackend();
      }
    } catch (e) {
      _syncError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> _refreshFromBackend() async {
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      debugPrint('🔌 Synchronizing mobile_client lists with backend: $_baseUrl');

      // Fetch Rooms
      final roomsRes = await http.get(Uri.parse('$_baseUrl/org/rooms')).timeout(const Duration(seconds: 15));
      if (roomsRes.statusCode == 200) {
        final List data = json.decode(roomsRes.body);
        _availableRooms = data.map((json) => OrgRoom(
          id: json['id'],
          name: json['name'],
          domain: json['domain'],
          isVerified: json['is_verified'] == true || json['is_verified'] == 1,
          joinMode: json['join_mode'] ?? 'Invite-only',
        )).toList();
        
        if (_currentRoom == null && _availableRooms.isNotEmpty) {
          _currentRoom = _availableRooms.first;
        }
      }

      // Fetch Events
      final eventsRes = await http.get(Uri.parse('$_baseUrl/events')).timeout(const Duration(seconds: 15));
      if (eventsRes.statusCode == 200) {
        final List data = json.decode(eventsRes.body);
        _events = data.map((json) {
          String dateText = '18 OCT';
          String timeText = '04:00 PM';
          try {
            final dateStr = json['date'];
            if (dateStr != null && dateStr.toString().isNotEmpty) {
              final parsed = DateTime.parse(dateStr).toLocal();
              const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
              final day = parsed.day.toString().padLeft(2, '0');
              final monthStr = months[parsed.month - 1];
              dateText = '$day $monthStr';

              final hourRaw = parsed.hour;
              final hour = hourRaw % 12 == 0 ? 12 : hourRaw % 12;
              final minute = parsed.minute.toString().padLeft(2, '0');
              final amPm = hourRaw >= 12 ? 'PM' : 'AM';
              timeText = '${hour.toString().padLeft(2, '0')}:$minute $amPm';
            }
          } catch (e) {
            debugPrint('⚠️ Failed to parse event date: $e');
          }

          final accepted = json['accepted_count'] ?? (json['id'].hashCode % 2 == 0 ? 34 : 42);
          final pending = json['pending_count'] ?? (json['id'].hashCode % 2 == 0 ? 12 : 15);
          final declined = json['declined_count'] ?? (json['id'].hashCode % 2 == 0 ? 3 : 4);

          return OrgEvent(
            id: json['id'],
            roomId: json['room_id'] ?? 'rm_creative_space',
            title: json['name'],
            hostName: json['host'] ?? _currentRoom?.name ?? 'Emantra Workspace',
            dateText: dateText,
            timeText: timeText,
            venue: json['venue'],
            notes: json['notes'] ?? '',
            price: (json['price'] as num?)?.toDouble() ?? 0.0,
            isFree: json['is_free'] == true || json['is_free'] == 1,
            isLive: json['is_live'] == true || json['is_live'] == 1,
            bannerUrl: json['cover_url'],
            rawDateTime: DateTime.tryParse(json['date'] ?? json['date_time'] ?? ''),
            acceptedCount: accepted,
            pendingCount: pending,
            declinedCount: declined,
          );
        }).toList();
      }

      // Fetch Contacts
      final contactsRes = await http.get(Uri.parse('$_baseUrl/contacts')).timeout(const Duration(seconds: 15));
      if (contactsRes.statusCode == 200) {
        final List data = json.decode(contactsRes.body);
        _contacts = data.map((json) => AppContact(
          id: json['id'],
          name: json['name'],
          email: json['email'],
          phone: json['phone'] ?? '+1 (555) 012-3456',
          notes: json['notes'] ?? '',
          category: json['category'] ?? 'Colleague',
        )).toList();
      }

      _syncError = null;
      notifyListeners();
      debugPrint('✅ Synchronization complete! Database records fetched dynamically.');
    } catch (e) {
      debugPrint('❌ Direct D1 Cloud Connection Error: $e');
      _syncError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // --- 3. Mutations & Requests Pipelines ---

  Future<void> login(String email, String password) async {
    if (isMockMode) {
      if (email.trim().toLowerCase() != 'alex.morgan@emantra.app') {
        throw Exception('Invalid credentials! Please use the demo email "alex.morgan@emantra.app" to log in.');
      }
      _currentUser = AppUser(
        id: 'usr_902183',
        name: 'Alex Morgan',
        email: email,
        role: 'Organizer',
        avatarUrl: 'https://api.dicebear.com/7.x/initials/png?seed=Alex%20Morgan',
      );
      _token = 'mock-jwt-token-alex-morgan';
      await _savePersistedSession();
      await _loadFromMockAsset();
      notifyListeners();
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final userJson = data['user'];
        _currentUser = AppUser(
          id: userJson['id'],
          name: userJson['name'],
          email: userJson['email'],
          role: userJson['role'] ?? 'Member',
          avatarUrl: userJson['avatar_url'],
        );
        _token = data['access_token'];
        debugPrint('🔓 Login validated via backend for: ${userJson['email']}');
        await _savePersistedSession();
      } else {
        final errBody = json.decode(res.body);
        throw Exception(errBody['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      debugPrint('❌ Network Login Failed: $e');
      rethrow;
    }
    await _refreshFromBackend();
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    if (isMockMode) {
      _currentUser = AppUser(
        id: 'usr_mock_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        role: 'Organizer',
        avatarUrl: 'https://api.dicebear.com/7.x/initials/png?seed=$name',
      );
      _token = 'mock-jwt-token-$name';
      await _savePersistedSession();
      await _loadFromMockAsset();
      notifyListeners();
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final userJson = data['user'];
        _currentUser = AppUser(
          id: userJson['id'],
          name: userJson['name'],
          email: userJson['email'],
          role: userJson['role'] ?? 'Member',
          avatarUrl: userJson['avatar_url'],
        );
        _token = data['access_token'];
        await _savePersistedSession();
      } else {
        final errBody = json.decode(res.body);
        throw Exception(errBody['message'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('❌ Network Register Failed: $e');
      rethrow;
    }
    notifyListeners();
  }

  Future<void> sendForgotPasswordLink(String email) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (email.trim().isEmpty || !email.contains('@')) {
        throw Exception('Invalid email address format.');
      }
      // Generate a mock recovery token
      final token = 'mock-reset-${DateTime.now().millisecondsSinceEpoch}';
      _resetTokens[email.trim().toLowerCase()] = token;
      debugPrint('🔑 [Mock Auth] Generated password recovery token for $email: $token');
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        final errBody = json.decode(res.body);
        throw Exception(errBody['message'] ?? 'Failed to send reset link');
      }
    } catch (e) {
      debugPrint('❌ Network Forgot Password Failed: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email, String token, String password) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      final lowercaseEmail = email.trim().toLowerCase();
      if (!_resetTokens.containsKey(lowercaseEmail) || _resetTokens[lowercaseEmail] != token) {
        throw Exception('Invalid or expired recovery token.');
      }
      _resetTokens.remove(lowercaseEmail);
      debugPrint('🔑 [Mock Auth] Password reset successfully for $email');
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'token': token, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        final errBody = json.decode(res.body);
        throw Exception(errBody['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      debugPrint('❌ Network Reset Password Failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    _mockSseTimer?.cancel();
    _mockSseTimer = null;
    _currentUser = null;
    _currentRoom = null;
    _token = null;
    await _clearPersistedSession();
    notifyListeners();
  }

  Future<void> createRoom(String name, String domain) async {
    if (isMockMode) {
      final newRoom = OrgRoom(
        id: 'rm_mock_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        domain: domain,
        isVerified: false,
        joinMode: 'Invite-only',
      );
      _availableRooms.add(newRoom);
      _currentRoom = newRoom;
      notifyListeners();
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/org/setup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'domain': domain, 'join_mode': 'Invite-only'}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final newRoom = OrgRoom(
          id: data['id'],
          name: data['name'],
          domain: data['domain'],
          isVerified: data['is_verified'] == true || data['is_verified'] == 1,
          joinMode: data['join_mode'] ?? 'Invite-only',
        );
        _availableRooms.add(newRoom);
        _currentRoom = newRoom;
      } else {
        final errBody = json.decode(res.body);
        throw Exception(errBody['message'] ?? 'Failed to create room');
      }
    } catch (e) {
      debugPrint('❌ Network CreateRoom Failed: $e');
      rethrow;
    }
    notifyListeners();
  }

  void selectRoom(OrgRoom room) {
    _currentRoom = room;
    notifyListeners();
  }

  Future<void> verifyCurrentRoom() async {
    if (isMockMode) {
      if (_currentRoom != null) {
        final updated = OrgRoom(
          id: _currentRoom!.id,
          name: _currentRoom!.name,
          domain: _currentRoom!.domain,
          isVerified: true,
          joinMode: _currentRoom!.joinMode,
        );
        _currentRoom = updated;
        final idx = _availableRooms.indexWhere((r) => r.id == updated.id);
        if (idx != -1) _availableRooms[idx] = updated;
        notifyListeners();
      }
      return;
    }

    if (_currentRoom != null) {
      try {
        final res = await http.post(
          Uri.parse('$_baseUrl/org/verify/${_currentRoom!.id}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'admin_email': 'admin@${_currentRoom!.domain}'}),
        ).timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final updated = OrgRoom(
            id: data['id'],
            name: data['name'],
            domain: data['domain'],
            isVerified: data['is_verified'] == true || data['is_verified'] == 1,
            joinMode: data['join_mode'] ?? 'Invite-only',
          );
          _currentRoom = updated;
          final idx = _availableRooms.indexWhere((r) => r.id == updated.id);
          if (idx != -1) _availableRooms[idx] = updated;
        } else {
          final errBody = json.decode(res.body);
          throw Exception(errBody['message'] ?? 'Verification failed');
        }
      } catch (e) {
        debugPrint('❌ Network VerifyRoom Failed: $e');
        rethrow;
      }
      notifyListeners();
    }
  }

  void setJoinMode(String mode) {
    if (_currentRoom != null) {
      final updated = OrgRoom(
        id: _currentRoom!.id,
        name: _currentRoom!.name,
        domain: _currentRoom!.domain,
        isVerified: _currentRoom!.isVerified,
        joinMode: mode,
      );
      _currentRoom = updated;
      final idx = _availableRooms.indexWhere((r) => r.id == updated.id);
      if (idx != -1) _availableRooms[idx] = updated;
      notifyListeners();
    }
  }

  void addChannel(String name, {bool isPrivate = false, String? roomId}) {
    final targetRoomId = roomId ?? _currentRoom?.id ?? _availableRooms.firstOrNull?.id ?? 'rm_creative_space';
    _channels.add(OrgChannel(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      roomId: targetRoomId,
      name: name,
      description: 'A newly created channel in the workspace.',
      unreadCount: 0,
      isPrivate: isPrivate,
    ));
    notifyListeners();
  }

  void removeParticipantFromChannel(String channelId, String contactId) {
    final list = getChannelParticipants(channelId);
    list.removeWhere((c) => c.id == contactId);
    notifyListeners();
  }

  Future<void> createEvent({
    required String title,
    required String host,
    required String dateText,
    required String timeText,
    required String venue,
    required String notes,
    required double price,
    required bool isFree,
    String? isoDate,
  }) async {
    final rawDt = DateTime.tryParse(isoDate ?? '');
    final now = DateTime.now();
    final computedIsLive = rawDt != null && rawDt.year == now.year && rawDt.month == now.month && rawDt.day == now.day;

    if (isMockMode) {
      final newEvent = OrgEvent(
        id: 'evt_mock_${DateTime.now().millisecondsSinceEpoch}',
        roomId: _currentRoom?.id ?? 'rm_creative_space',
        title: title,
        hostName: host,
        dateText: dateText,
        timeText: timeText,
        venue: venue,
        notes: notes,
        price: price,
        isFree: isFree,
        isLive: computedIsLive,
        bannerUrl: 'https://api.dicebear.com/7.x/identicon/png?seed=$title',
        rawDateTime: rawDt,
        acceptedCount: 1,
        pendingCount: 0,
        declinedCount: 0,
      );
      _events.add(newEvent);
      notifyListeners();
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/events'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': title,
          'venue': venue,
          'date': isoDate ?? '2026-10-18T16:00:00Z',
          'price': price,
          'is_free': isFree,
          'notes': notes,
          'room_id': _currentRoom?.id ?? 'rm_creative_space',
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final newEvent = OrgEvent(
          id: data['id'],
          roomId: data['room_id'] ?? _currentRoom?.id ?? 'rm_creative_space',
          title: data['name'],
          hostName: host,
          dateText: dateText,
          timeText: timeText,
          venue: data['venue'],
          notes: data['notes'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          isFree: data['is_free'] == true || data['is_free'] == 1,
          isLive: data['is_live'] == true || data['is_live'] == 1 || computedIsLive,
          bannerUrl: data['cover_url'],
          rawDateTime: DateTime.tryParse(data['date'] ?? isoDate ?? ''),
          acceptedCount: 1,
          pendingCount: 0,
          declinedCount: 0,
        );
        _events.add(newEvent);
      } else {
        final errBody = json.decode(res.body);
        throw Exception(errBody['message'] ?? 'Failed to create event');
      }
    } catch (e) {
      debugPrint('❌ Network CreateEvent Failed: $e');
      rethrow;
    }
    notifyListeners();
  }

  void deleteRoom() {
    if (_currentRoom != null) {
      _availableRooms.removeWhere((r) => r.id == _currentRoom!.id);
      _currentRoom = _availableRooms.isNotEmpty ? _availableRooms.first : null;
      notifyListeners();
    }
  }

  Future<void> addContact({
    required String name,
    required String email,
    required String phone,
    required String notes,
    required String category,
  }) async {
    if (isMockMode) {
      _contacts.add(AppContact(
        id: 'con_mock_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        notes: notes,
        category: category,
      ));
      notifyListeners();
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/contacts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'category': category,
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        _contacts.add(AppContact(
          id: data['id'],
          name: data['name'],
          email: data['email'],
          phone: phone,
          notes: notes,
          category: data['category'] ?? category,
        ));
      } else {
        final errBody = json.decode(res.body);
        throw Exception(errBody['message'] ?? 'Failed to add contact');
      }
    } catch (e) {
      debugPrint('❌ Network AddContact Failed: $e');
      rethrow;
    }
    notifyListeners();
  }

  Future<void> editContact({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String notes,
    required String category,
  }) async {
    if (isMockMode) {
      final idx = _contacts.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _contacts[idx] = AppContact(
          id: id,
          name: name,
          email: email,
          phone: phone,
          notes: notes,
          category: category,
        );
        notifyListeners();
      }
      return;
    }

    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/contacts/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'category': category,
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final idx = _contacts.indexWhere((c) => c.id == id);
        if (idx != -1) {
          _contacts[idx] = AppContact(
            id: id,
            name: data['name'],
            email: data['email'],
            phone: phone,
            notes: notes,
            category: data['category'] ?? category,
          );
        }
      } else {
        final errBody = json.decode(res.body);
        throw Exception(errBody['message'] ?? 'Failed to edit contact');
      }
    } catch (e) {
      debugPrint('❌ Network EditContact Failed: $e');
      rethrow;
    }
    notifyListeners();
  }

  Future<void> deleteContact(String id) async {
    if (isMockMode) {
      _contacts.removeWhere((c) => c.id == id);
      notifyListeners();
      return;
    }

    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/contacts/$id'),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 204) {
        _contacts.removeWhere((c) => c.id == id);
      } else {
        throw Exception('Failed to delete contact');
      }
    } catch (e) {
      debugPrint('❌ Network DeleteContact Failed: $e');
      rethrow;
    }
    notifyListeners();
  }

  void addGuest({
    required String eventId,
    required String name,
    required String email,
    required GuestStatus status,
    required String category,
  }) {
    _guests.add(EventGuest(
      id: 'g-${DateTime.now().millisecondsSinceEpoch}',
      eventId: eventId,
      name: name,
      email: email,
      status: status,
      category: category,
    ));
    notifyListeners();
  }

  void updateGuestStatus(String id, GuestStatus status) {
    final index = _guests.indexWhere((g) => g.id == id);
    if (index != -1) {
      final oldGuest = _guests[index];
      _guests[index] = EventGuest(
        id: oldGuest.id,
        eventId: oldGuest.eventId,
        name: oldGuest.name,
        email: oldGuest.email,
        avatarUrl: oldGuest.avatarUrl,
        status: status,
        category: oldGuest.category,
      );
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> askAgent(String message) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 1200)); // Simulate think time
      
      final msgLower = message.toLowerCase();
      String reply = "I am your offline Emantra AI companion. I can help you automate guests and workspace management when connected to a live server.";
      String action = "none";
      
      if (msgLower.contains('contact') || msgLower.contains('add') || msgLower.contains('invite')) {
        addContact(
          name: 'Bob Ross',
          email: 'bob.ross@canvas.com',
          phone: '+1-555-4321',
          notes: 'Added automatically via AI assistant simulation.',
          category: 'Colleague',
        );
        reply = "Certainly! I've automatically added 'Bob Ross' (bob.ross@canvas.com) to your contacts. You can verify this in the Contacts tab.";
        action = "add_contact";
      } else if (msgLower.contains('channel') || msgLower.contains('room')) {
        addChannel('ai-insights-deck', isPrivate: true);
        reply = "Workspace channel automated! I have established a private channel '#ai-insights-deck' in your current room.";
        action = "create_channel";
      } else if (msgLower.contains('rsvp') || msgLower.contains('gala') || msgLower.contains('guest') || msgLower.contains('elon')) {
        addGuest(
          eventId: 'evt_summer_gala',
          name: 'Elon Musk',
          email: 'elon@spacex.com',
          status: GuestStatus.accepted,
          category: 'VIP',
        );
        reply = "RSVP processed! I have registered 'Elon Musk' as 'ACCEPTED' (VIP category) for the Annual Summer Gala. Check the Guest tab to confirm.";
        action = "rsvp_updated";
      } else {
        reply = "Hello! I am Emantra's agentic AI co-pilot. While we are offline in mock mode, I can still simulate common workflows. Try asking me to 'add a contact', 'create a channel', or 'rsvp Elon Musk' to see me interact with the client state!";
      }
      
      notifyListeners();
      return {
        'reply': reply,
        'action': action,
      };
    }

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/agent/chat'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode({'message': message}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        // Automatically sync the backend dynamic lists on success
        await _refreshFromBackend();
        return {
          'reply': data['reply'] ?? 'Completed that action.',
          'action': data['action'] ?? 'none',
        };
      } else {
        final errBody = json.decode(res.body);
        throw Exception(errBody['message'] ?? 'Failed to get agent response');
      }
    } catch (e) {
      debugPrint('❌ askAgent Failed: $e');
      rethrow;
    }
  }

  Map<String, String> _parseDateTime(String? dateTimeStr) {
    String dateText = 'TBD';
    String timeText = '--:--';
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return {'dateText': dateText, 'timeText': timeText};
    }
    try {
      final parsed = DateTime.parse(dateTimeStr).toLocal();
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      final day = parsed.day.toString().padLeft(2, '0');
      final monthStr = months[parsed.month - 1];
      dateText = '$day $monthStr';

      final hourRaw = parsed.hour;
      final hour = hourRaw % 12 == 0 ? 12 : hourRaw % 12;
      final minute = parsed.minute.toString().padLeft(2, '0');
      final amPm = hourRaw >= 12 ? 'PM' : 'AM';
      timeText = '${hour.toString().padLeft(2, '0')}:$minute $amPm';
    } catch (e) {
      debugPrint('⚠️ Failed to parse event date: $e');
    }
    return {'dateText': dateText, 'timeText': timeText};
  }

  void _startMockSseSimulation() {
    _mockSseTimer?.cancel();
    
    // Every 6 seconds, simulate a new RSVP arriving!
    _mockSseTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!isMockMode) {
        timer.cancel();
        return;
      }
      
      final eventIds = _events.map((e) => e.id).toList();
      if (eventIds.isEmpty) return;
      
      // Rotate target event with each tick
      final targetEventId = eventIds[timer.tick % eventIds.length];
      final isAccepted = (timer.tick % 5 != 0); // 80% accepted, 20% declined
      final nextStatus = isAccepted ? GuestStatus.accepted : GuestStatus.declined;
      final nextStatusStr = isAccepted ? 'Accepted' : 'Declined';
      
      // Look for a guest that is currently pending for this event, and update status!
      final pendingGuests = _guests.where((g) => g.eventId == targetEventId && g.status == GuestStatus.pending).toList();
      if (pendingGuests.isNotEmpty) {
        final guestToUpdate = pendingGuests.first;
        final index = _guests.indexWhere((g) => g.id == guestToUpdate.id);
        if (index != -1) {
          _guests[index] = EventGuest(
            id: guestToUpdate.id,
            eventId: guestToUpdate.eventId,
            name: guestToUpdate.name,
            email: guestToUpdate.email,
            avatarUrl: guestToUpdate.avatarUrl,
            status: nextStatus,
            category: guestToUpdate.category,
          );
          
          debugPrint('📡 [Simulated SSE] RSVP status changed for ${guestToUpdate.name} on event $targetEventId (Pending -> $nextStatusStr)!');
          notifyListeners();
        }
      } else {
        // If all pre-loaded pending guests are accepted/declined, create a new guest from mock contacts!
        final eventGuestEmails = _guests.where((g) => g.eventId == targetEventId).map((g) => g.email.toLowerCase()).toSet();
        final eligibleContacts = _contacts.where((c) => !eventGuestEmails.contains(c.email.toLowerCase())).toList();
        if (eligibleContacts.isNotEmpty) {
          final contact = eligibleContacts.first;
          String category = contact.category;
          if (category == 'Colleagues') category = 'Colleague';
          if (category == 'Friends') category = 'Friend';
          
          _guests.add(EventGuest(
            id: 'gst_${DateTime.now().millisecondsSinceEpoch}',
            eventId: targetEventId,
            name: contact.name,
            email: contact.email,
            status: nextStatus,
            category: category,
          ));
          
          debugPrint('📡 [Simulated SSE] New RSVP ($nextStatusStr) registered for ${contact.name} on event $targetEventId!');
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _mockSseTimer?.cancel();
    super.dispose();
  }
}
