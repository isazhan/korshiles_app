import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ad_view.dart';
import 'filter_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = ApiService().getHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        body: Column(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('Sort');
                  },
                  child: Text('Sort'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FilterView()),
                    );
                  },
                  child: Text('Filter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    //shrinkWrap: true,
                    //physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 10),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                          margin: EdgeInsets.only(bottom: 5),
                          elevation: 5,
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AdView(
                                          ad: snapshot.data![index]['ad'])),
                                );
                              },
                              child: ListTile(
                                title: Text(
                                    snapshot.data![index]['ad'].toString()),
                                subtitle: Text(
                                  snapshot.data![index]['info'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )));
                    },
                  );
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ]));
  }
}

class ApiService {
  final String apiUrl = "http://0.0.0.0:8000/api/index";

  Future<List<dynamic>> getHomeData() async {
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
}
