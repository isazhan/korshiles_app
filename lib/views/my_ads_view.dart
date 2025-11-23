import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/api.dart';
import '../widgets/bar.dart';
import '../globals.dart' as globals;
import '../widgets/ad_card_my.dart';

class MyAdsView extends StatefulWidget {
  final String? user;

  MyAdsView({super.key, required this.user});

  @override
  _MyAdsViewState createState() => _MyAdsViewState();
}

class _MyAdsViewState extends State<MyAdsView> {
  List<dynamic> _data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyAds();
  }

  Future<void> _fetchMyAds() async {
    try {
      final ads = await ApiService().justGet('api/api_my_ads', {'phone_number': widget.user});
      setState(() {
        _data = ads['ads'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching my ads: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: globals.myBackColor,
      body: Column(
        children: [

          // Title
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Мои объявления',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ) 
                ),
              )
            ]
          ),

          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(              
              color: Colors.blue.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Объявления автоматически удаляются через 7 дней',
              style: TextStyle(
                //color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),          

          // Ads List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _data.isEmpty
                    ? Center(child: Text('У вас нет объявлений.'))
                    : ListView.builder(
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          return AdCardMy(
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
                            publish: _data[index]['publish'],
                          );
                        },
                      ),
          ),


        ],
      ),
    );
  }
}