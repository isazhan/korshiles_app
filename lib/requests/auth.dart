import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../globals.dart' as globals;
import 'package:flutter/material.dart';
import '../main.dart';


class AuthService {
  final baseUrl = globals.host;
  final storage = const FlutterSecureStorage();
  //AuthService(this.baseUrl);


  Future<Map<String, dynamic>> login(phonenumber, code, password, newpassword) async {
    final url = Uri.parse('$baseUrl/api/api_login');
    final resp = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phonenumber,
        'code': code,
        'password': password,
        'password_new': newpassword,
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


  Future<bool> refreshToken() async {
    final refresh = await storage.read(key: 'refresh');
    if (refresh == null) return false;

    final url = Uri.parse('$baseUrl/api/api_refresh_token');
    final resp = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      await storage.write(key: 'access', value: data['access']);
      if (data.containsKey('refresh')) {
        await storage.write(key: 'refresh', value: data['refresh']);
      }
      return true;
    }
    return false;
  }

  Future<bool> isLoggedIn() async {
    final access = await storage.read(key: 'access');
    final refresh = await storage.read(key: 'refresh');
    return access != null && refresh != null;
  }

}