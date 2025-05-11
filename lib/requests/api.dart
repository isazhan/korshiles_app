import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //static const host = '127.0.0.1:8000';
  static const host = 'korshiles.kz';

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
}
