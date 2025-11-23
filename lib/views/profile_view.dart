import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/auth.dart';
import '../widgets/bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../globals.dart' as globals;
import 'my_ads_view.dart';

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
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService().loadUserName();
    setState(() {
      _userName = user;
    });
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить аккаунт'),
          content: const Text('Вы уверены, что хотите удалить аккаунт?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Удалить'),
              onPressed: () {
                //ApiService().deleteAccount();
                AuthService().logout(context);
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Аккаунт удален')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            appBar: CustomAppBar(),
            backgroundColor: globals.myBackColor,
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [

                      //Number
                      Expanded(
                        child: Container(
                          //margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 48,
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

                    ],
                  ),
                ),
                
                
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      // My ads
                      ListTile(
                        leading: Icon(Icons.list, color: globals.myColor,),
                        title: Text('Мои объявления'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyAdsView(user: _userName,)),
                          );
                        },
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      SizedBox(height: 10,),
                      // Delete account
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.red,),
                        title: Text('Удалить аккаунт'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          _showConfirmationDialog(context);
                        },
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      
                      SizedBox(height: 10,),
                      // Logout
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red,),
                        title: Text('Выйти'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          AuthService().logout(context);
                        },
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
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