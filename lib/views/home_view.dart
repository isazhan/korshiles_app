import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/api.dart';
import '../widgets/bar.dart';
import 'ad_view.dart';
import 'filter_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<dynamic> _data = [];
  String selectedCity = '';
  String selectedDistrict = '';
  String selectedPage = '';

  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _refreshData({'page': '1', 'type': '', 'city': '', 'district': ''});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 && !isLoading) {
          _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      isLoading = true;
    });
    try {
      final moreData = await ApiService().getAds({
        'page': (int.parse(selectedPage) + 1).toString(),
        'type': '',
        'city': selectedCity,
        'district': selectedDistrict,
      });
      setState(() {
        _data.addAll(moreData);
        selectedPage = (int.parse(selectedPage) + 1).toString();
      });
    } catch (e) {
      print('Error loading more ads: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData(filter) async {
    try {
      final refreshedData = await ApiService().getAds(filter);
      setState(() {
        _data = refreshedData;
        selectedCity = filter['city'] ?? '';
        selectedDistrict = filter['district'] ?? '';
        selectedPage = filter['page'] ?? '1';
      });
    } catch (e) {
      print('Error fetching ads: $e');
    }
  }

  void previousPage() {
    _refreshData({'page': (int.parse(selectedPage)-1).toString(), 'type': '', 'city': '', 'district': ''});
  }

  void nextPage() {
    _refreshData({'page': (int.parse(selectedPage)+1).toString(), 'type': '', 'city': '', 'district': ''});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(children: [
        
        // Filter and Sort buttons
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //color: Colors.white,
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Объявления'),
              Spacer(),
              SizedBox(
                height: 30,
                child: VerticalDivider(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.swap_vert,
                  color: Colors.blue,
                  )
              ),
              SizedBox(
                height: 30,
                child: VerticalDivider(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.tune,
                  color: Colors.blue,
                  )
              ),              
            ],
          ),
        ),
        
        // Ads List
        Expanded(child:
      ListView.builder(
        controller: _scrollController,
        itemCount: _data.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {


          if (index == _data.length) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Card(
                              margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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
                                        _data[index]['type']['ru'].toString() + ' ' + _data[index]['ad'].toString(),
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
                                                Text(_data[index]['city']['ru'] ?? ''),
                                                //Text(_data[index]['district']['ru'] ?? ''),
                                                const SizedBox(height: 16),
                                                Text(
                                                  _data[index]['info'],
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  _data[index]['create_time'] ?? '',
                                                  textAlign: TextAlign.right,
                                                ),
                                              ]))
                                        ],
                                      )
                                    ],
                                  )));
        }
      ),
        ),

      ]),
    );
  }
}
/*
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
*/