import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../globals.dart' as globals;
import 'package:flutter/material.dart';
import '../main.dart';


class AuthService {
  final baseUrl = globals.host;
  final storage = const FlutterSecureStorage();


  Future<Map<String, dynamic>> login(phonenumber, code, password, newpassword, forget) async {
    final url = Uri.parse('$baseUrl/api/api_login');
    final resp = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phonenumber,
        'code': code,
        'password': password,
        'password_new': newpassword,
        'forget': forget,
      })
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['status'] == 'login') {
        await storage.write(key: 'access', value: data['access']);
        await storage.write(key: 'refresh', value: data['refresh']);
        await storage.write(key: 'user', value: jsonEncode(data['user']));
      }
      return data;
    } else {
      throw Exception('Failed to authenticate user');
    }
  }


  Future<void> logout(context) async {
    final refresh = await storage.read(key: 'refresh');
    
    if (refresh != null) {
      final url = Uri.parse('$baseUrl/api/api_logout');
      await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}));
    }

    await storage.deleteAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MyHomePage()),
      (route) => false,
    );
  }


  Future<bool> isLoggedIn() async {
    final access = await storage.read(key: 'access');
    final refresh = await storage.read(key: 'refresh');
    
    // Simple check: both tokens must be present
    if (access == null || refresh == null) {
      return false;
    }

    // Check if access token is expired on server
    final response = await http.get(
      Uri.parse('$baseUrl/api/api_check_token'),
      headers: {'Authorization': 'Bearer $access'},
    );

    // If access token is valid, return true
    if (response.statusCode == 200) {
      return true;
    }

    // If access token is invalid, try to refresh it
    final refreshResponse = await http.post(
      Uri.parse('$baseUrl/api/api_refresh_token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (refreshResponse.statusCode == 200) {
      final data = jsonDecode(refreshResponse.body);

      // Getting new access token
      await storage.write(key: 'access', value: data['access']);

      return true;
    }

    // If refresh token is also invalid, return false
    await storage.delete(key: 'access');
    await storage.delete(key: 'refresh');
    return false;
  }


  Future<String> loadUserName() async {
    final userJson = await storage.read(key: 'user');    
    final user = jsonDecode(userJson!);
    return user['phone_number'];    
  }

  Future<bool> loadStaff() async {
    final userJson = await storage.read(key: 'user');    
    final user = jsonDecode(userJson!);
    return user['is_staff'];
  }

}