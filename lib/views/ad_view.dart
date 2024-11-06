import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdView extends StatelessWidget {
  AdView({super.key, required this.ad});

  final int ad;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(child: Text(ad.toString())),
    );
  }
}

class ApiService1 {
  final String apiUrl = "http://0.0.0.0:8000/api/ad";

  Future<List<dynamic>> getAdData(String ad) async {
    try {
      final response = await http.post(Uri.parse(apiUrl),
          body: jsonEncode(<String, String>{
            'ad': ad,
          }));

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
