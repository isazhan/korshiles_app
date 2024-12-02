import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/api.dart';
import '../widgets/bar.dart';
import 'ad_view.dart';
import 'filter_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    refreshData({'type': ''});
  }

  Future<void> refreshData(filter) async {
    try {
      final refreshedData = await ApiService().getAds(filter);
      setState(() {
        _data = refreshedData;
      });
    } catch (e) {
      print('Error fetching ads: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        body: Column(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.blueGrey,
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
                  onPressed: () async {
                    final filters = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FilterView()),
                    );
                    if (filters != null) {
                      refreshData(filters);
                    }
                  },
                  child: Text('Filter'),
                ),
              ],
            ),
          ),
          Expanded(
              child: _data.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      //shrinkWrap: true,
                      //physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 10),
                      itemCount: _data.length,
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
                                            ad: _data[index]['ad'].toString())),
                                  );
                                },
                                child: ListTile(
                                  title: Text(_data[index]['ad'].toString()),
                                  subtitle: Text(
                                    _data[index]['info'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )));
                      },
                    ))
        ]));
  }
}
