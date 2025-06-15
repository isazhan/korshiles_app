import 'dart:convert';
import 'ad_view.dart';
import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/api.dart';
import '../widgets/bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_view.dart';
import '../controllers/nav_controller.dart';
import '../controllers/auth_controller.dart';
import 'package:intl/intl.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);
  
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final storage = const FlutterSecureStorage();
  String? _userName;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }
  
  Future<void> _loadUserName() async {
    final userJson = await storage.read(key: 'user');
    
    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        _userName = user['phone_number']; // Adjust based on your actual user field
      });
      await _loadMyAds();
    }
  }

  Future<void> _loadMyAds() async {
    final response = await ApiService().getMyAds(_userName);
    if (response != null) {
      setState(() {
        _data = response['ads'] ?? [];
      });
    }
  }

  void logout(BuildContext context) async {
    await ApiService().logout();
    AuthController.isLoggedIn = false;
    navIndexNotifier.value = 0; // Switch to HomeView
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ApiService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            appBar: CustomAppBar(),
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [

                      //Number
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.only(left: 10),
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(_userName ?? 'Загрузка...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ), 
                        ),
                      ),

                      //Logout Button
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () => logout(context),
                          icon: Icon(
                            Icons.logout,
                            color: Colors.blue,
                            )
                        ),
                      ),

                    ],
                  ),
                ),

                // Text
                Container(
                  //margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.only(left: 10),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Мои объявления',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ), 
                ),

                // My Ads List
                Expanded(child: 
                  ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: (_data[index]['publish'] == true)
                                              ? Colors.green[100]
                                              : Colors.orange[100],
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          (_data[index]['publish'] == true)
                                              ? 'Опубликовано'
                                              : 'На проверке',
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),

                                      Row(
                                        children: <Widget>[
                                          Image.asset(
                                            'static/img/no-image.png',
                                            width: 150,
                                          ),
                                          const SizedBox(width: 10),
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
                                                Row(
                                                  children: [
                                                    Icon(Icons.visibility, color: Colors.grey, size: 16),
                                                    Text(_data[index]['views'].toString()),
                                                    Spacer(),
                                                    Text(
                                                      DateFormat('d.MM.yyyy').format(DateTime.parse(_data[index]['create_time'].toString())).toString(),
                                                    ),
                                                  ],
                                                ),
                                              ]))
                                        ],
                                      )
                                    ],
                                  ))
                      );
                    },
                  )
                ),
              

              
              ],              
            )
            

          );
        } else {
          
          return const SizedBox(); // placeholder
        }
      },
    );
  }
}