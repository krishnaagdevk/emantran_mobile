import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../app/widgets/status_chip.dart';
import '../models/models.dart';

class ApiRepository extends ChangeNotifier {
  // --- API Endpoint Resolutions ---
  String get _baseUrl {
    try {
      final envUrl = dotenv.get('API_URL', fallback: '');
      final isPhysical = dotenv.get('PHYSICAL_DEVICE', fallback: 'false') == 'true';
      if (envUrl.isNotEmpty) {
        if (Platform.isAndroid && envUrl.contains('localhost') && !isPhysical) {
          return envUrl.replaceAll('localhost', '10.0.2.2');
        }
        return envUrl;
      }
    } catch (_) {}
    
    // Default fallback (uses 10.0.2.2 for Android emulator, localhost otherwise)
    final isPhysicalDefault = dotenv.get('PHYSICAL_DEVICE', fallback: 'false') == 'true';
    if (Platform.isAndroid) {
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

  bool _isSyncing = false;
  String? _syncError;

  // --- Getters ---
  AppUser? get currentUser => _currentUser;
  String? get token => _token;
  OrgRoom? get currentRoom => _currentRoom;
  List<OrgRoom> get availableRooms => List.unmodifiable(_availableRooms);
  List<OrgChannel> get channels => List.unmodifiable(_channels);
  List<OrgEvent> get events => List.unmodifiable(_events);
  List<AppContact> get contacts => List.unmodifiable(_contacts..sort((a, b) => a.name.compareTo(b.name)));
  List<EventGuest> get guests => List.unmodifiable(_guests);
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
          name: j['name'],
          unreadCount: j['unread_count'] ?? 0,
        )).toList();
      }

      if (data['events'] != null) {
        final List eventsList = data['events'];
        _events = eventsList.map((j) {
          return OrgEvent(
            id: j['id'],
            title: j['name'],
            hostName: j['host'] ?? _currentRoom?.name ?? 'Emantra Workspace',
            dateText: "28 JUL",
            timeText: "06:00 PM",
            venue: j['location'] ?? j['venue'] ?? '',
            notes: j['description'] ?? j['notes'] ?? '',
            price: (j['price'] as num?)?.toDouble() ?? 0.0,
            isFree: j['is_free'] == true || (j['price'] == null || j['price'] == 0.0),
            isLive: j['is_live'] == true,
            bannerUrl: j['image_url'] ?? j['cover_url'],
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

      _syncError = null;
      debugPrint('✅ Unified mock database loaded successfully from assets!');
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
      if (isMockMode) {
        await _loadFromMockAsset();
      } else {
        await _refreshFromBackend();
      }
    } catch (_) {}
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

          final accepted = json['accepted_count'] ?? (json['id'] % 2 == 0 ? 34 : 42);
          final pending = json['pending_count'] ?? (json['id'] % 2 == 0 ? 12 : 15);
          final declined = json['declined_count'] ?? (json['id'] % 2 == 0 ? 3 : 4);

          return OrgEvent(
            id: json['id'],
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
          category: json['category'] ?? 'Colleagues',
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

  Future<void> logout() async {
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

  void addChannel(String name) {
    _channels.add(OrgChannel(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      unreadCount: 0,
    ));
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
    if (isMockMode) {
      final newEvent = OrgEvent(
        id: 'evt_mock_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        hostName: host,
        dateText: dateText,
        timeText: timeText,
        venue: venue,
        notes: notes,
        price: price,
        isFree: isFree,
        isLive: true,
        bannerUrl: 'https://api.dicebear.com/7.x/identicon/png?seed=$title',
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
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final newEvent = OrgEvent(
          id: data['id'],
          title: data['name'],
          hostName: host,
          dateText: dateText,
          timeText: timeText,
          venue: data['venue'],
          notes: data['notes'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          isFree: data['is_free'] == true || data['is_free'] == 1,
          isLive: data['is_live'] == true || data['is_live'] == 1,
          bannerUrl: data['cover_url'],
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
    required String name,
    required String email,
    required GuestStatus status,
    required String category,
  }) {
    _guests.add(EventGuest(
      id: 'g-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      status: status,
      category: category,
    ));
    notifyListeners();
  }

  Future<Map<String, dynamic>> askAgent(String message) async {
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
}
