import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../globals.dart' as globals;
import 'package:image_picker/image_picker.dart';

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


  Future<Map<String, dynamic>> postMultipartWithAuth(
    String endpoint,
    Map<String, dynamic> fields,
    List<XFile> images,
  ) async {
    final access = await storage.read(key: 'access');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    if (access != null) {
      request.headers['Authorization'] = 'Bearer $access';
    }

    // common fields
    fields.forEach((key, value) {
      if (value == null) {
        request.fields[key] = '';
      } else {
        request.fields[key] = value.toString();
      }
    });

    // files
    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception(responseBody);
    }
  }


}