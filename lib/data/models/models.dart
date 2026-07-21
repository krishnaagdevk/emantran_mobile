import '../../app/widgets/status_chip.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role; // Admin, Member

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
  });

  String get domain => email.contains('@') ? email.split('@').last : '';
}

class OrgRoom {
  final String id;
  final String name;
  final String domain;
  final bool isVerified;
  final String joinMode; // Invite-only, Open

  OrgRoom({
    required this.id,
    required this.name,
    required this.domain,
    required this.isVerified,
    required this.joinMode,
  });
}

class OrgChannel {
  final String id;
  final String roomId;
  final String name;
  final String description;
  final int unreadCount;
  final bool isPrivate;

  OrgChannel({
    required this.id,
    required this.roomId,
    required this.name,
    required this.description,
    this.unreadCount = 0,
    this.isPrivate = false,
  });
}

class OrgEvent {
  final String id;
  final String roomId;
  final String title;
  final String hostName;
  final String dateText;
  final String timeText;
  final String venue;
  final String notes;
  final double price;
  final bool isFree;
  final bool isLive;
  final String? bannerUrl;
  final DateTime? rawDateTime;
  
  // RSVP numbers
  final int acceptedCount;
  final int pendingCount;
  final int declinedCount;

  OrgEvent({
    required this.id,
    required this.roomId,
    required this.title,
    required this.hostName,
    required this.dateText,
    required this.timeText,
    required this.venue,
    required this.notes,
    required this.price,
    required this.isFree,
    this.isLive = false,
    this.bannerUrl,
    this.rawDateTime,
    this.acceptedCount = 0,
    this.pendingCount = 0,
    this.declinedCount = 0,
  });

  int get totalInvited => acceptedCount + pendingCount + declinedCount;
}

class AppContact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String notes;
  final String category; // Family, Friend, Colleague, VIP, None

  AppContact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.notes,
    required this.category,
  });
}

class EventGuest {
  final String id;
  final String eventId;
  final String name;
  final String email;
  final String? avatarUrl;
  final GuestStatus status;
  final String category;

  EventGuest({
    required this.id,
    required this.eventId,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.status,
    required this.category,
  });
}

class ContactCategories {
  ContactCategories._();

  static const String colleague = 'Colleague';
  static const String vip = 'VIP';
  static const String vvip = 'VVIP';
  static const String friend = 'Friend';
  static const String family = 'Family';
  static const String bridesFamily = "Bride's Family";
  static const String groomsFamily = "Groom's Family";
  static const String none = 'None';

  static const List<String> values = [
    colleague,
    vip,
    vvip,
    friend,
    family,
    bridesFamily,
    groomsFamily,
    none,
  ];
}

class ChatMessage {
  final String id;
  final String channelId;
  final String senderName;
  final String senderEmail;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderName,
    required this.senderEmail,
    required this.text,
    required this.timestamp,
  });
}
