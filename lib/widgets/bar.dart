import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
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