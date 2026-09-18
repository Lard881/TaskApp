import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Production API URL from Render
  static const String _productionUrl = 'https://planpal-backend-bprw.onrender.com/api';
  
  static String get baseUrl {
    // Use production URL for all platforms
    return _productionUrl;
    
    // For local development, uncomment below and comment out the return above:
    // if (kIsWeb) {
    //   return 'http://localhost:3000/api';
    // }
    // switch (defaultTargetPlatform) {
    //   case TargetPlatform.android:
    //     return 'http://10.0.2.2:3000/api';
    //   default:
    //     return 'http://localhost:3000/api';
    // }
  }

  static const String _tokenKey = 'planpal_auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, String>> headers({bool includeAuth = true}) async {
    final token = await loadToken();
    return {
      'Content-Type': 'application/json',
      if (includeAuth && token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }
}

Future<http.Response> apiGet(String path) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}$path');
  return http.get(uri, headers: await ApiConfig.headers());
}

Future<http.Response> apiPost(String path, [Map<String, dynamic>? body]) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}$path');
  return http.post(
    uri,
    headers: await ApiConfig.headers(),
    body: body == null ? null : jsonEncode(body),
  );
}

Future<http.Response> apiPut(String path, [Map<String, dynamic>? body]) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}$path');
  return http.put(
    uri,
    headers: await ApiConfig.headers(),
    body: body == null ? null : jsonEncode(body),
  );
}

Future<http.Response> apiDelete(String path) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}$path');
  return http.delete(uri, headers: await ApiConfig.headers());
}
