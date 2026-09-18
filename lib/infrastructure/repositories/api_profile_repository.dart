import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/infrastructure/repositories/api_client.dart';
import 'package:planpal/infrastructure/repositories/user_repository.dart';

class ApiProfileRepository implements UserRepository {
  @override
  Future<User?> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode == 401 || response.statusCode == 403) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load profile.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return User(
      id: payload['id'] as String,
      firstName: payload['first_name'] as String? ?? '',
      lastName: payload['last_name'] as String? ?? '',
      email: payload['email'] as String? ?? '',
      role: payload['role'] as String?,
      phone: payload['phone'] as String?,
      avatarPath: payload['avatar_url'] as String?,
    );
  }

  @override
  Future<List<User>> getAll() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profile/users'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load users.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((json) {
      final data = json as Map<String, dynamic>;
      return User(
        id: data['id'] as String,
        firstName: data['first_name'] as String? ?? '',
        lastName: data['last_name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        role: data['role'] as String?,
        phone: data['phone'] as String?,
        avatarPath: data['avatar_url'] as String?,
      );
    }).toList();
  }

  @override
  Future<User?> getById(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profile/users/$id'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load user.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return User(
      id: data['id'] as String,
      firstName: data['first_name'] as String? ?? '',
      lastName: data['last_name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String?,
      phone: data['phone'] as String?,
      avatarPath: data['avatar_url'] as String?,
    );
  }

  @override
  Future<void> save(User user) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: await ApiConfig.headers(),
      body: jsonEncode({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'role': user.role,
        'phone': user.phone,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to save profile.');
    }
  }

  /// Upload avatar image and update profile
  Future<String> uploadAvatar({
    required String base64Image,
    required String fileName,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/profile/avatar'),
      headers: await ApiConfig.headers(),
      body: jsonEncode({
        'base64Image': base64Image,
        'fileName': fileName,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to upload avatar.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['avatarUrl'] as String;
  }

  @override
  Stream<User?> watchCurrentUser() {
    // Poll every 15 seconds for profile updates
    return Stream.periodic(const Duration(seconds: 15))
        .asyncMap((_) => getCurrentUser())
        .handleError((error) {
      return null;
    });
  }
}