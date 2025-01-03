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
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _refreshData({'type': ''});
  }

  Future<void> _refreshData(filter) async {
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
                  child: Text('Сортировать'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final filters = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FilterView()),
                    );
                    if (filters != null) {
                      _refreshData(filters);
                    }
                  },
                  child: Text('Фильтр'),
                ),
              ],
            ),
          ),
          Expanded(
              child: _data.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _refreshData({'type': ''}),
                      child: ListView.builder(
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
                                              ad: _data[index]['ad']
                                                  .toString())),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _data[index]['type']['ru'].toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Image.asset(
                                            'static/img/no-image.png',
                                            width: 150,
                                          ),
                                          Flexible(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                Text(
                                                    _data[index]['city']['ru']),
                                                Text(_data[index]['district']
                                                    ['ru']),
                                                const SizedBox(height: 16),
                                                Text(
                                                  _data[index]['info'],
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ]))
                                        ],
                                      )
                                    ],
                                  )));
                        },
                      )))
        ]));
  }
}
