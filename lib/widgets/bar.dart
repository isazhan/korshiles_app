import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:korshiles_app/main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool exit;

  const CustomAppBar({this.exit = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return AppBar(
      leading: exit
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop(); // Close the current screen
                '''
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => MyHomePage()),
                  (route) => false,
                );
                ''';
              },
            )
          : null,
      title: Row(
        children: [
          Image.asset(
            'static/img/logo.png',
          ),
          Text(
            'Көршілес',
            style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Nunito, sans-serif', fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(5),
          ),
          margin: EdgeInsets.only(right: 10),
          child: PopupMenuButton(         
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(lang=='kk' ? 'ҚАЗ' : 'РУС', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Nunito, sans-serif', fontWeight: FontWeight.w600)),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: Text('Қазақша'),
                onTap: () {
                  MyApp.of(context).changeLanguage('kk');
                },
              ),
              PopupMenuItem(
                child: Text('Русский'),
                onTap: () {
                  MyApp.of(context).changeLanguage('ru');
                },
              ),
            ],
          ),
        )        
      ],
      backgroundColor: globals.myColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}