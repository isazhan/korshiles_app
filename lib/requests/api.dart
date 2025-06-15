import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  //static const host = '127.0.0.1:8000';
  static const host = 'korshiles.kz';
  //static const host = '10.0.2.2:8000';

  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getAds(filter) async {
    final apiUrl = Uri.http(host, '/api/index', filter);
    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<Map<String, dynamic>> getAd(ad) async {
    final apiUrl = Uri.http(host, '/api/ad', {'ad': ad});
    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<Map<String, dynamic>> login(phonenumber, code, password, newpassword) async {
    final response = await http.post(
      Uri.parse('https://$host/api/api_login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phonenumber,
        'code': code,
        'password': password,
        'password_new': newpassword,
        }),
    );
    //print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to authenticate user');
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('https://$host/api/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  Future<void> logout() async {
    final access = await storage.read(key: 'access');
    final refresh = await storage.read(key: 'refresh');
    
    if (access == null || refresh == null) {
      throw Exception('Missing tokens');
    }

    final response = await http.post(
      Uri.parse('https://$host/api/api_logout'),
      headers: {
        'Authorization': 'Bearer $access',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 205) {
      await storage.deleteAll();
    }
  }

  Future<bool> isLoggedIn() async {
    final accessToken = await storage.read(key: 'access');
    if (accessToken == null) return false;

    final response = await http.get(
      Uri.parse('https://$host/api/api_check_token'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return response.statusCode == 200;
  }

  Future<String> createAd(adData) async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    Future<String?> getAccessToken() async {
      return await secureStorage.read(key: 'access');
    }
    final access = await getAccessToken();
    final response = await http.post(
      Uri.parse('https://$host/api/api_create_ad'),
      headers: {
        'Authorization': 'Bearer $access',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(adData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['status'];
    } else {
      throw Exception('Failed to create ad');
    }
  }
}
