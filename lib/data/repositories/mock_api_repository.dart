import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// =========================================================================
/// 🎨 MOBILE CLIENT EXAMPLE SERVICE READER
/// 
/// This class serves as a direct blueprint demonstrating how the Flutter client
/// parses and instantiates strongly-typed entities from our shared mock_data.json.
/// =========================================================================

class MockUserSchema {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  MockUserSchema({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory MockUserSchema.fromJson(Map<String, dynamic> json) {
    return MockUserSchema(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'Member',
      avatarUrl: json['avatar_url'],
    );
  }
}

class MockDataService {
  /// Loads the master centralized dataset from the Flutter bundle assets
  static Future<Map<String, dynamic>> loadMasterDataset() async {
    try {
      final jsonString = await rootBundle.loadString('assets/mock_data.json');
      return json.decode(jsonString);
    } catch (e) {
      throw Exception('Failed to load centralized mock data: $e');
    }
  }

  /// Extracts and parses the currentUser entity
  static Future<MockUserSchema> fetchMockUser() async {
    final data = await loadMasterDataset();
    if (data['currentUser'] == null) {
      throw Exception('currentUser not present in mock_data.json');
    }
    return MockUserSchema.fromJson(data['currentUser']);
  }
}
