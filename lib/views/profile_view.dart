import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/api.dart';
import '../widgets/bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_view.dart';
import '../controllers/nav_controller.dart';
import '../controllers/auth_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);
  
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final storage = const FlutterSecureStorage();
  String? _userName;

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
                )
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