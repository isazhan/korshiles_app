import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:korshiles_app/main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool exit;

  const CustomAppBar({this.exit = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        PopupMenuButton(
          icon: Icon(Icons.language, color: Colors.white),
          iconSize: 30,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              child: Text('Қазақша'),
              //value: 'kz',
              onTap: () {
                MyApp.of(context).changeLanguage('kk');
              },
            ),
            PopupMenuItem(
              child: Text('Русский'),
              //value: 'ru',
              onTap: () {
                MyApp.of(context).changeLanguage('ru');
              },
            ),
          ],
        )
      ],
      backgroundColor: globals.myColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}