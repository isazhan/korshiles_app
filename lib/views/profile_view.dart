import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/auth.dart';
import '../widgets/bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../globals.dart' as globals;
import 'my_ads_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);
  
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final storage = const FlutterSecureStorage();
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final staff = await AuthService().loadStaff();
    setState(() {
      _isStaff = staff;
    });
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Аккаунтты жою'),
          content: Text('Аккаунтты жоюға сенімдісіз бе?'),
          actions: <Widget>[
            TextButton(
              child: Text('Кері қайту'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Аккаунтты жою'),
              onPressed: () {
                //ApiService().deleteAccount();
                AuthService().logout(context);
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Аккаунт жойылды')),
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
    final lang = Localizations.localeOf(context).languageCode;
    
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
                      alignment: Alignment.center,
                      child: Text(lang=='kk' ? 'Сәлем 👋' : 'Привет 👋',
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
                  title: Text(lang=='kk' ? 'Менің хабарландыруларым' : 'Мои объявления'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyAdsView(user: FirebaseAuth.instance.currentUser?.uid ?? '',)),
                    );
                  },
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),                
                
                SizedBox(height: 20,),
                Text(lang=='kk' ? 'Бізбен байланыс' : 'Связаться с нами'),
                SizedBox(height: 10,),

                // Telegram
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.telegram, color: Colors.blue),
                  title: Text('Telegram'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async{
                          final Uri url = Uri(scheme: 'https', host: 't.me', path: 'korshiles');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                SizedBox(height: 10,),

                // Whatsapp
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                  title: Text('WhatsApp'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async{
                          final Uri url = Uri(scheme: 'https', host: 'wa.me', path: '+77474232744');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                SizedBox(height: 10,),

                // Threads
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.threads, color: Colors.black),
                  title: Text('Threads'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async{
                          final Uri url = Uri(scheme: 'https', host: 'threads.net', path: '@korshiles.kz');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Version
                  Text(
                    lang == 'kk' ? 'Қосымша нұсқасы: 1.0.15' : 'Версия приложения: 1.0.15',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  // UserID
                  Text(
                    FirebaseAuth.instance.currentUser?.uid ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ]
              )
            ),
          ),


        ],
      )
    );

  }
}