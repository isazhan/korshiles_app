import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../globals.dart' as globals;

class ApiService {
  final baseUrl = globals.host;
  final storage = const FlutterSecureStorage();
  

  Future<Map<String, dynamic>> justGet(endpoint, data) async {
    final apiUrl = Uri.parse('$baseUrl$endpoint').replace(queryParameters: data);

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


  Future<Map<String, dynamic>> postWithAuth(endpoint, data) async {
    final access = await storage.read(key: 'access');
    
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (access != null) 'Authorization': 'Bearer $access',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}