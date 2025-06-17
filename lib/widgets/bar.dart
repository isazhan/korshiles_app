import 'package:flutter/material.dart';
import '../main.dart';
import '../controllers/nav_controller.dart';

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
      backgroundColor: Color.fromRGBO(22, 151, 209, 1),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}