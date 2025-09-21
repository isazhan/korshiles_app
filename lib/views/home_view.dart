import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/api.dart';
import '../widgets/bar.dart';
import 'filter_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../widgets/ad_card.dart';
import '../globals.dart' as globals;

class HomeView extends StatefulWidget {
  final AdSize adSize;
  final String adUnitId = Platform.isAndroid
    // for Andriod
    ? 'ca-app-pub-5754778099148012/4385493179'
    // for iOS
    : 'ca-app-pub-3940256099942544/6300978111';

  HomeView({super.key, this.adSize = AdSize.largeBanner});

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
  BannerAd? _bannerAd;

  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _refreshData({'page': '1', 'type': '', 'city': '', 'district': ''});
    _loadAd();
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
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _refreshData(filter) async {
    try {
      final refreshedData = await ApiService().getAds(filter);
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

  void previousPage() {
    _refreshData({'page': (int.parse(selectedPage)-1).toString(), 'type': '', 'city': '', 'district': ''});
  }

  void nextPage() {
    _refreshData({'page': (int.parse(selectedPage)+1).toString(), 'type': '', 'city': '', 'district': ''});
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Color.fromRGBO(240, 240, 240, 1),
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
                    child: Text(totalAds.toString() + ' объявления',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ), 
                ),
              ),
              
              //Sort button
              Container(
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.swap_vert,
                    color: Colors.blue,
                    )
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

          // Admob
          if (index == 2) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: widget.adSize.width.toDouble(),
              height: widget.adSize.height.toDouble(),
              child: _bannerAd == null
                  ? const SizedBox()
                  : AdWidget(ad: _bannerAd!),
            );
          }
          return AdCard(
            title: _data[index]['type']['ru'],
            ad: _data[index]['ad'].toString(),
            photos: (_data[index]['photos'] != null)
                ? globals.host + _data[index]['photos'][0]
                : 'no',
            city: _data[index]['city']['ru'],
            district: (_data[index]['district'] != '')
                ? _data[index]['district']['ru']
                : '',
            description: _data[index]['info'],
            views: _data[index]['views'].toString(),
            date: _data[index]['create_time'].toString(),
          );
        }
      ))
        ),

      ]),
    );
  }
}