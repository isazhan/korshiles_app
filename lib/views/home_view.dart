import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/api.dart';
import '../widgets/bar.dart';
import 'filter_view.dart';
import '../widgets/ad_card.dart';
import '../globals.dart' as globals;
import '../admob/native1.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<dynamic> _data = [];
  String selectedType = '';
  String selectedCity = '';
  String selectedDistrict = '';
  String selectedPage = '';
  int totalAds = 0;

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
      final moreData = await ApiService().justGet('api/index', {
        'page': (int.parse(selectedPage) + 1).toString(),
        'type': selectedType,
        'city': selectedCity,
        'district': selectedDistrict,
      });
      setState(() {
        _data.addAll(moreData['ads'] ?? []);
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
      final refreshedData = await ApiService().justGet('api/index', filter);
      setState(() {
        _data = refreshedData['ads'] ?? [];
        selectedType = filter['type'] ?? '';
        selectedCity = filter['city'] ?? '';
        selectedDistrict = filter['district'] ?? '';
        selectedPage = filter['page'] ?? '1';
        totalAds = refreshedData['total'] ?? 0;
      });
    } catch (e) {
      print('Error fetching ads: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: globals.myBackColor,
      body: Column(children: [

        // Filter and Sort buttons
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //color: Colors.white,
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Number of ads
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.only(left: 10),
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(lang=='kk'
                        ? totalAds.toString() + ' хабарландыру'
                        : totalAds.toString() + ' объявлений',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ), 
                ),
              ),
              

              //Filter button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () async {
                  final filters = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FilterView()),
                  );
                  if (filters != null) {
                    _refreshData(filters);
                  }
                },
                  icon: Icon(
                    Icons.tune,
                    color: Colors.blue,
                    )
                ),
              ),
                            
            ],
          ),
        ),

        // Ads List
        Expanded(child:
        RefreshIndicator(
          onRefresh: () => _refreshData({'page': '1', 'type': selectedType, 'city': selectedCity, 'district': selectedCity}),
          child: ListView.builder(
        controller: _scrollController,
        itemCount: _data.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {


          if (index == _data.length) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }          

          // Common ad
          final adCard = AdCard(
            title: _data[index]['type'][lang],
            ad: _data[index]['ad'].toString(),
            photos: (_data[index]['photos'] != null)
                ? globals.host + _data[index]['photos'][0]
                : 'no',
            city: _data[index]['city'][lang],
            district: (_data[index]['district'] != '')
                ? _data[index]['district'][lang]
                : '',
            description: _data[index]['info'],
            views: _data[index]['views'].toString(),
            date: _data[index]['create_time'].toString(),
          );

          if (index == 2) {
            return Column(
              children: [
                NativeAdWidget(),
                adCard,
              ],
            );
          }

          return adCard;
        }
      ))
      ),
      ]),
    );
  }
}