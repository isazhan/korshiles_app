import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const host = '0.0.0.0:8000';

  Future<List<dynamic>> getAds(filter) async {
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

  Future<Map<String, dynamic>> getAd(String ad) async {
    const String apiUrl = "http://0.0.0.0:8000/api/ad";
    final Map<String, dynamic> data = {
      'ad': ad,
    };
    try {
      final response = await http.post(Uri.parse(apiUrl), body: data);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
