import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/auth.dart';
import 'views/home_view.dart';
import 'views/create_view.dart';
import 'views/profile_view.dart';
import 'views/login_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'globals.dart' as globals;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) unawaited(MobileAds.instance.initialize());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Korshiles',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final _screens = [
    HomeView(),
    CreateView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) async {
    if (index != 0) {
      final loggedIn = await AuthService().isLoggedIn();
      if (!loggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
        return;
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: globals.myColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Подать'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Кабинет'),
        ],
      ),
    );
  }
}