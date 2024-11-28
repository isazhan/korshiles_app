import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<dynamic>> getHomeData() async {
    final String apiUrl = "http://0.0.0.0:8000/api/index";
    try {
      final response = await http.get(Uri.parse(apiUrl));

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

  Future<void> getFilter() async {
    const String apiUrl = "http://0.0.0.0:8000/api/filter";
    final Map<String, dynamic> data = {
      'key1': 'value1',
      'key2': 'value2',
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
